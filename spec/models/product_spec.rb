require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:user) { User.create!(name: "Test User", email: "test@example.com", password: "password") }

  subject do
    described_class.new(
      name: "Sample Product",
      description: "A sample product",
      price: 100.50,
      is_bundle: false,
      metadata: { color: "red" },
      created_by_user: user
    )
  end

  describe "associations" do
    it { should have_many(:bundled_products).with_foreign_key(:bundle_id) }
    it { should have_many(:components).through(:bundled_products) }
    it { should have_many(:inverse_bundled_products).with_foreign_key(:component_id) }
    it { should have_many(:bundles).through(:inverse_bundled_products) }

    it "belongs to created_by_user" do
      assoc = described_class.reflect_on_association(:created_by_user)
      expect(assoc.macro).to eq(:belongs_to)
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is not valid without a name" do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    it "is not valid without a created_by_user" do
      subject.created_by_user = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:created_by_user]).to include("must exist")
    end

    it "is not valid with negative price" do
      subject.price = -10
      expect(subject).not_to be_valid
      expect(subject.errors[:price]).to include("must be greater than or equal to 0")
    end

    it "generates a unique 8-character SKU before validation" do
      product = described_class.create!(
        name: "Coffee",
        price: 10,
        is_bundle: false,
        created_by_user: user
      )
      expect(product.sku.length).to eq(8)
      expect(product.sku).to match(/[A-Z0-9]{8}/)
    end

    it "does not allow creation if product with same SKU already exists" do
      # First product is created successfully
      first = described_class.create!(
        name: "Coffee",
        price: 10,
        is_bundle: false,
        created_by_user: user
      )

      # Second product with same name should fail
      second = described_class.new(
        name: "Coffee",
        price: 15,
        is_bundle: false,
        created_by_user: user
      )

      expect(second).not_to be_valid
      expect(second.errors[:base]).to include("Product with this name or SKU already exists")
    end
  end
end
