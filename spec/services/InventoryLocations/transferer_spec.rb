require 'rails_helper'

RSpec.describe InventoryLocations::Transferer, type: :service do
  # -------------------------
  # Base data (seed-style)
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
      capacity: 100
    )
  end

  let!(:to_location) do
    InventoryLocation.create!(
      storage_id: "BIN-02",
      warehouse: warehouse,
      unique_item_limits: 1,
      capacity: 100
    )
  end

  let!(:product) do
    Product.create!(
      name: "Coffee",
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
  # Payload MUST match service expectations
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
  # Mocked inventory details
  # -------------------------
  let(:mock_source_inventory_data) do
    [ {
      "inventory_summary_id" => source_summary.id,
      "inventory_status_id" => sellable.id,
      "status" => "Sellable",
      "sku" => product.sku,
      "quantity_on_hand" => 50,
      "reserved_quantity" => 5
    } ]
  end

  let(:mock_destination_inventory_data) { [] }

  before do
    source_stub = instance_double(InventoryLocations::CurrentInventoryDetails)
    dest_stub   = instance_double(InventoryLocations::CurrentInventoryDetails)

    allow(InventoryLocations::CurrentInventoryDetails)
      .to receive(:new)
      .with(from_location.id)
      .and_return(source_stub)

    allow(InventoryLocations::CurrentInventoryDetails)
      .to receive(:new)
      .with(to_location.id)
      .and_return(dest_stub)

    allow(source_stub).to receive(:call).and_return(mock_source_inventory_data)
    allow(dest_stub).to receive(:call).and_return(mock_destination_inventory_data)
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
        expect { subject.call }
          .to change(InventorySummary, :count)
          .by(2)
      end

      it "creates two InventoryMovement records" do
        expect { subject.call }
          .to change(InventoryMovement, :count)
          .by(2)
      end

      it "reduces quantity at source location" do
        subject.call

        new_source_summary =
          InventorySummary
            .where(inventory_location: from_location)
            .order(id: :desc)
            .first

        expect(new_source_summary.quantity_on_hand).to eq(40)
        expect(new_source_summary.reserved_quantity).to eq(5)
      end

      it "creates destination summary with moved quantity" do
        subject.call

        dest_summary =
          InventorySummary
            .where(inventory_location: to_location)
            .order(id: :desc)
            .first

        expect(dest_summary.quantity_on_hand).to eq(10)
        expect(dest_summary.reserved_quantity).to eq(0)
        expect(dest_summary.product).to eq(product)
      end
    end

    context "when unique item limit is violated" do
      let!(:other_product) do
        Product.create!(
          name: "Tea",
          sku: "TEA",
          price: 5,
          created_by_user: user
        )
      end

      let!(:existing_dest_summary) do
        InventorySummary.create!(
          product: other_product,
          inventory_location: to_location,
          inventory_status: sellable,
          quantity_on_hand: 5,
          reserved_quantity: 0
        )
      end

      let(:mock_destination_inventory_data) do
        [ {
          "inventory_summary_id" => existing_dest_summary.id,
          "inventory_status_id" => sellable.id,
          "status" => "Sellable",
          "sku" => other_product.sku,
          "quantity_on_hand" => 5,
          "reserved_quantity" => 0
        } ]
      end

      it "returns false and rolls back changes" do
        expect(subject.call).to be false

        expect(InventorySummary.count).to eq(2)
        expect(InventoryMovement.count).to eq(0)

        expect(source_summary.reload.quantity_on_hand).to eq(50)
      end
    end
  end
end
