require 'rails_helper'

RSpec.describe InventoryLocations::Transferer, type: :service do
  # -------------------------
  # Base data
  # -------------------------
  let!(:user) do
    User.create!(
      name: "Test User",
      email: "test@example.com",
      password: "password"
    )
  end

  let!(:warehouse) do
    Warehouse.create!(
      name: "Main Warehouse",
      address: "123 Warehouse St"
    )
  end

  let!(:sellable) { InventoryStatus.create!(name: "Sellable") }

  let!(:from_location) do
    InventoryLocation.create!(
      storage_id: "BIN-01",
      warehouse: warehouse,
      unique_item_limits: 5,
      capacity: 200
    )
  end

  let!(:to_location) do
    InventoryLocation.create!(
      storage_id: "BIN-02",
      warehouse: warehouse,
      unique_item_limits: 1,
      capacity: 200
    )
  end

  let!(:product) do
    Product.create!(
      name: "Coffee",
      brand: 'Test',
      sku: "COF",
      price: 10,
      created_by_user: user
    )
  end

  let!(:source_summary) do
    InventorySummary.create!(
      product: product,
      inventory_location: from_location,
      inventory_status: sellable,
      quantity_on_hand: 50,
      reserved_quantity: 5
    )
  end

  # -------------------------
  # Payload
  # -------------------------
  let(:transfer_quantity) { 10 }
  let(:payload) do
    {
      source_summary.id.to_s => {
        "quantity" => transfer_quantity
      }
    }
  end

  let(:params) do
    ActionController::Parameters.new(
      source_location_id: from_location.id,
      destination_location_id: to_location.id,
      items: payload
    )
  end

  # -------------------------
  # Mocked inventory details - Dynamic Fix
  # -------------------------
  before do
    # This block intercepts EVERY call to .new(id)
    allow(InventoryLocations::CurrentInventoryDetails).to receive(:new) do |loc_id|
      # Generate a fresh instance double for every single call
      mock_stub = instance_double(InventoryLocations::CurrentInventoryDetails)

      # Determine which data to return based on the ID passed from the model
      data = if loc_id == from_location.id
               [ {
                 "inventory_summary_id" => source_summary.id,
                 "inventory_status_id" => sellable.id,
                 "status" => "Sellable",
                 "sku" => product.sku,
                 "quantity_on_hand" => 50,
                 "reserved_quantity" => 5
               } ]
      else
               # Use an instance variable so we can change this in specific contexts
               @mock_destination_inventory_data || []
      end

      # Tell this specific double to return the correct data
      allow(mock_stub).to receive(:call).and_return(data)
      mock_stub
    end
  end

  subject { described_class.new(params) }

  # -------------------------
  # Tests
  # -------------------------
  describe "#call" do
    context "when destination location is empty" do
      it "returns true" do
        expect(subject.call).to be true
      end

      it "creates two InventorySummary records" do
        expect { subject.call }.to change(InventorySummary, :count).by(2)
      end

      it "reduces quantity at source location" do
        subject.call
        new_source_summary = InventorySummary.where(inventory_location: from_location).order(id: :desc).first
        expect(new_source_summary.quantity_on_hand).to eq(40)
      end
    end

    context "when unique item limit is violated" do
      let!(:other_product) do
        Product.create!(
          name: "Tea",
          brand: 'Test',
          sku: "TEA",
          price: 5,
          created_by_user: user
        )
      end

      before do
        # 1. Update the variable that the global stub uses
        @mock_destination_inventory_data = [ {
          "inventory_summary_id" => 999,
          "inventory_status_id" => sellable.id,
          "status" => "Sellable",
          "sku" => "TEA",
          "quantity_on_hand" => 5,
          "reserved_quantity" => 0
        } ]

        # 2. Create the summary. The callback will trigger, hit our dynamic stub, and work!
        InventorySummary.create!(
          product: other_product,
          inventory_location: to_location,
          inventory_status: sellable,
          quantity_on_hand: 5,
          reserved_quantity: 0
        )
      end

      it "returns false and rolls back changes" do
        # This will now fail correctly because the destination has "TEA"
        # and the Transferer is trying to move "COF" (exceeding limit of 1)
        expect(subject.call).to be false
        expect(source_summary.reload.quantity_on_hand).to eq(50)
      end
    end
  end
end
