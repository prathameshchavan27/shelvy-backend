require 'rails_helper'

RSpec.describe BundledProduct, type: :model do
  describe "asspciations" do
    it { should belong_to(:bundle).class_name('Product') }
    it { should belong_to(:component).class_name('Product') }
  end

  describe "validations" do
    let(:user) { User.create!(name: "Test User", email: "test@example.com", password: "password") }
    let(:bundle) { Product.create!(sku: "BUNDLE1", name: "Bundle Product", is_bundle: true, price: 10, created_by_user: user) }
    let(:component) { Product.create!(sku: "COMP1", name: "Component Product", is_bundle: false, price: 5, created_by_user: user) }

    it "is valid with bundle and component" do
      bundled_product = BundledProduct.new(bundle: bundle, component: component, quantity: 2)
      expect(bundled_product).to be_valid
    end

    it "is invalid if bundle == component (self-cycle)" do
      bundled_product = BundledProduct.new(bundle: bundle, component: bundle, quantity: 2)
      expect(bundled_product).not_to be_valid
    end

    it "is invalid if bundle is not a bundle product" do
      not_a_bundle = Product.create!(sku: "NOTBUNDLE", name: "Not a Bundle", is_bundle: false, price: 5, created_by_user: user)
      bundled_product = BundledProduct.new(bundle: not_a_bundle, component: component, quantity: 2)
      expect(bundled_product).not_to be_valid
    end

    it "is invalid if component is a bundle product" do
      component = Product.create!(sku: "COMPBUNDLE", name: "Component Bundle", is_bundle: true, price: 15, created_by_user: user)
      bundled_product = BundledProduct.new(bundle: bundle, component: component, quantity: 2)
      expect(bundled_product).not_to be_valid
    end
  end
end
