require 'rails_helper'

RSpec.describe InventoryLocation, type: :model do
  let(:warehouse) { Warehouse.create(name: "Pune", address: "1234 Street") }
  let(:user) { User.create!(name: "Tester", email: "tester@example.com", password: "password") }

  subject {
    InventoryLocation.new(
      storage_id: "BIN-001",
      unique_item_limits: 5,
      capacity: 150,
      warehouse: warehouse
    )
  }

  describe "associations" do
    it { should belong_to(:warehouse) }
    it { should have_many(:products).dependent(:nullify) }
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is not valid without a warehouse" do
      subject.warehouse = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:warehouse]).to include("must exist")
    end

    it "is not valid with negative capacity" do
      subject.capacity = -10
      expect(subject).not_to be_valid
    end

    it "is not valid with zero capacity" do
      subject.capacity = 0
      expect(subject).not_to be_valid
    end

    it "is valid if capacity is nil (optional)" do
      subject.capacity = nil
      expect(subject).to be_valid
    end

    it "is not valid with negative unique_item_limits" do
      subject.unique_item_limits = -2
      expect(subject).not_to be_valid
    end

    it "is not valid with zero unique_item_limits" do
      subject.unique_item_limits = 0
      expect(subject).not_to be_valid
    end

    it "is valid if unique_item_limits is nil (optional)" do
      subject.unique_item_limits = nil
      expect(subject).to be_valid
    end

    it "does not allow more unique products than unique_item_limits" do
      # Add 2 unique products → OK
      p1 = Product.create!(name: "Laptop", price: 10, created_by_user: user, inventory_location: subject)
      p2 = Product.create!(name: "Tea", price: 20, created_by_user: user, inventory_location: subject)
      p3 = Product.create!(name: "Watch", price: 10, created_by_user: user, inventory_location: subject)
      p4 = Product.create!(name: "Bag", price: 20, created_by_user: user, inventory_location: subject)
      p5 = Product.create!(name: "Hoodie", price: 10, created_by_user: user, inventory_location: subject)
      expect(subject.reload).to be_valid

      # Try to add a 3rd unique product → should fail
      p6 = Product.new(name: "Shoes", price: 30, created_by_user: user, inventory_location: subject)
      expect(p6.save).to be false
      expect(p6.errors[:inventory_location]).to include("has reached its unique product limit of 5")
    end
  end
end
