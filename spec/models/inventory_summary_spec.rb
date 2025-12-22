require 'rails_helper'

RSpec.describe InventorySummary, type: :model do
  let(:warehouse) { Warehouse.create!(name: "Main Warehouse", address: "123 Warehouse St") }
  let(:user) { User.create!(name: "Tester", email: "tester@example.com", password: "password") }
  let(:inventory_location) { InventoryLocation.create!(storage_id: "AEC-01", warehouse: warehouse, capacity: 500, unique_item_limits: 12) }
  let(:product) { Product.create!(name: "Test Product", price: 20.0, created_by_user: user) }
  let(:status) { InventoryStatus.create!(name: "Sellable") }

  subject do
    described_class.new(
      product: product,
      inventory_location: inventory_location,
      inventory_status: status,
      quantity_on_hand: 10,
      reserved_quantity: 2
    )
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is not valid without a product" do
      subject.product = nil
      is_expected.to_not be_valid
    end

    it "is not valid without an inventory location" do
      subject.inventory_location = nil
      is_expected.to_not be_valid
    end

    it "is not valid without an inventory_status" do
      subject.inventory_status = nil
      expect(subject).not_to be_valid
    end

    it "is not valid without quantity_on_hand" do
      subject.quantity_on_hand = nil
      is_expected.to_not be_valid
    end

    it "is not valid with negative quantity_on_hand" do
      subject.quantity_on_hand = -5
      is_expected.to_not be_valid
    end

    it "is not valid with negative reserved_quantity" do
      subject.reserved_quantity = -3
      is_expected.to_not be_valid
    end

    it "does not allow reserved_quantity to exceed quantity_on_hand" do
      subject.reserved_quantity = 15
      is_expected.to_not be_valid
    end
  end

  describe "associations" do
    it { should belong_to(:product) }
    it { should belong_to(:inventory_location) }
    it { should belong_to(:inventory_status) }
  end
end
