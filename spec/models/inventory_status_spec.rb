# spec/models/inventory_status_spec.rb
require 'rails_helper'

RSpec.describe InventoryStatus, type: :model do
  subject { described_class.new(name: "Sellable") }

  describe "validations" do
    it "is valid with a proper name" do
      expect(subject).to be_valid
    end

    it "is not valid without a name" do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    it "is not valid with an invalid name" do
      subject.name = "InvalidStatus"
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("InvalidStatus is not a valid inventory status")
    end

    it "enforces uniqueness of name" do
      described_class.create!(name: "Sellable")
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("has already been taken")
    end
  end

  describe "associations" do
    it { should have_many(:inventory_summaries).dependent(:nullify) }
  end
end

# spec/models/inventory_summary_spec.rb
require 'rails_helper'

RSpec.describe InventorySummary, type: :model do
  let(:user) { User.create!(name: "Tester", email: "test@example.com", password: "password") }
  let(:warehouse) { Warehouse.create!(name: "Main", address: "123 St") }
  let(:location) { InventoryLocation.create!(storage_id: "BIN-01", warehouse: warehouse) }
  let(:product) { Product.create!(name: "Coffee", price: 10, created_by_user: user, inventory_location: location) }
  let(:status) { InventoryStatus.create!(name: "Sellable") }

  subject do
    described_class.new(
      product: product,
      inventory_location: location,
      inventory_status: status,
      quantity_on_hand: 50,
      reserved_quantity: 5
    )
  end

  describe "validations" do
    it "is valid with all attributes" do
      expect(subject).to be_valid
    end

    it "is not valid without a product" do
      subject.product = nil
      expect(subject).not_to be_valid
    end

    it "is not valid without an inventory_location" do
      subject.inventory_location = nil
      expect(subject).not_to be_valid
    end

    it "is not valid without an inventory_status" do
      subject.inventory_status = nil
      expect(subject).not_to be_valid
    end

    it "is not valid if quantity_on_hand is negative" do
      subject.quantity_on_hand = -1
      expect(subject).not_to be_valid
    end

    it "is not valid if reserved_quantity is negative" do
      subject.reserved_quantity = -1
      expect(subject).not_to be_valid
    end

    it "is not valid if reserved_quantity exceeds quantity_on_hand" do
      subject.reserved_quantity = 100
      expect(subject).not_to be_valid
      expect(subject.errors[:reserved_quantity]).to include("cannot exceed quantity on hand")
    end
  end

  describe "associations" do
    it { should belong_to(:product) }
    it { should belong_to(:inventory_location) }
    it { should belong_to(:inventory_status) }
  end
end
