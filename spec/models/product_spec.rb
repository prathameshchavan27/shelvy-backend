require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:user) { User.create!(name: "Test User", email: "test@example.com", password: "password") }

  subject do
    described_class.new(
      sku: "SKU123",
      name: "Sample Product",
      description: "A sample product",
      price: 100.50,
      is_bundle: false,
      metadata: { color: "red" },
      created_by_user: user
    )
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is not valid without a sku" do
      subject.sku = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:sku]).to include("can't be blank")
    end

    it "is not valid with duplicate sku" do
      described_class.create!(
        sku: "SKU123",
        name: "Another Product",
        price: 50,
        is_bundle: false,
        created_by_user: user
      )
      expect(subject).not_to be_valid
      expect(subject.errors[:sku]).to include("has already been taken")
    end

    it "is not valid without a name" do
      subject.name = nil
      expect(subject).not_to be_valid
    end

    it "is not valid with negative price" do
      subject.price = -10
      expect(subject).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to created_by_user" do
      assoc = described_class.reflect_on_association(:created_by_user)
      expect(assoc.macro).to eq(:belongs_to)
    end
  end
end
