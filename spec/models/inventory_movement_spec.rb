require 'rails_helper'

RSpec.describe InventoryMovement, type: :model do
  describe InventoryMovement do
    let(:warehouse) { Warehouse.create!(name: "Main", address: "123 Warehouse St") }
    let(:location1) { InventoryLocation.create!(storage_id: "BIN-01", warehouse: warehouse, capacity: 300) }
    let(:location2) { InventoryLocation.create!(storage_id: "BIN-02", warehouse: warehouse, capacity: 300) }
    let(:user) { User.create!(name: "User1", email: "a@b.com", password: "123456") }
    let(:product) { Product.create!(name: "Coffee", price: 10, created_by_user: user, inventory_location: location1) }
    let(:status) { InventoryStatus.create!(name: "Sellable") }
    let(:summary) { InventorySummary.create!(product: product, inventory_location: location1, inventory_status: status, quantity_on_hand: 10, reserved_quantity: 0) }

    subject do
      described_class.new(
        inventory_summary: summary,
        transfer_from: location1,
        transfer_to: location2,
        quantity_moved: 5
      )
    end

    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is not valid without inventory_summary" do
      subject.inventory_summary = nil
      expect(subject).not_to be_valid
    end

    it "is not valid with non-positive quantity_moved" do
      subject.quantity_moved = 0
      expect(subject).not_to be_valid
    end

    it "requires at least one of transfer_from or transfer_to" do
      subject.transfer_from = nil
      subject.transfer_to = nil
      expect(subject).not_to be_valid
    end
  end
  describe "associations" do
    it "belongs to inventory_summary" do
      assoc = described_class.reflect_on_association(:inventory_summary)
      expect(assoc.macro).to eq(:belongs_to)
    end

    it "belongs to transfer_from (InventoryLocation)" do
      assoc = described_class.reflect_on_association(:transfer_from)
      expect(assoc.macro).to eq(:belongs_to)
      expect(assoc.class_name).to eq("InventoryLocation")
    end

    it "belongs to transfer_to (InventoryLocation)" do
      assoc = described_class.reflect_on_association(:transfer_to)
      expect(assoc.macro).to eq(:belongs_to)
      expect(assoc.class_name).to eq("InventoryLocation")
    end

    it "belongs to bundle (Product) optionally" do
      assoc = described_class.reflect_on_association(:bundle)
      expect(assoc.macro).to eq(:belongs_to)
      expect(assoc.class_name).to eq("Product")
    end
  end
end
