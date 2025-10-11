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
    it { should have_many(:inventory_summaries).dependent(:destroy) }
    it { should have_many(:products).through(:inventory_summaries) }
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
  end
end
