require 'rails_helper'

RSpec.describe Warehouse, type: :model do
  subject { described_class.new(name: "Main Warehouse", address: "1234 Street, City") }

  describe "associations" do
    it { should have_many(:inventory_locations).dependent(:destroy) }
  end

  describe "validations" do
    it "is valid with a name and address" do
      expect(subject).to be_valid
    end

    it "is not valid without a name" do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    it "is not valid without an address" do
      subject.address = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:address]).to include("can't be blank")
    end
  end
end
