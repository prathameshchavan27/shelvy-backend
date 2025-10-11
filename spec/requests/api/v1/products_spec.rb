require 'rails_helper'

RSpec.describe "Api::V1::Products", type: :request do
  let(:admin) { User.create!(name: "Admin", email: "admin@example.com", password: "password", role: :admin) }
  let(:manager) { User.create!(name: "Manager", email: "manager@example.com", password: "password", role: :manager) }
  let(:staff) { User.create!(name: "Staff", email: "staff@example.com", password: "password", role: :staff) }

  let(:warehouse) { Warehouse.create!(name: "Main Warehouse", address: "123 Street") }
  let(:bin1) { InventoryLocation.create!(storage_id: "BIN-01", warehouse: warehouse, capacity: 100, unique_item_limits: 5) }

  let!(:coffee) { Product.create!(name: "Coffee", price: 10, created_by_user: admin) }
  let!(:tea) { Product.create!(name: "Tea", price: 8, created_by_user: admin) }

  # Bundle example
  let!(:coffee_tea_bundle) { Product.create!(name: "Coffee & Tea Bundle", price: 17, is_bundle: true, created_by_user: admin) }
  let!(:bundle_relation) { BundledProduct.create!(bundle: coffee_tea_bundle, component: coffee, quantity: 1) }
  let!(:bundle_relation2) { BundledProduct.create!(bundle: coffee_tea_bundle, component: tea, quantity: 1) }

  describe "GET /index" do
    context "when user is authenticated" do
      it "returns all products" do
        get "/api/v1/products", headers:  auth_headers(admin)
        puts "Response status: #{response.body}"
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.size).to eq(3)
      end

      it "returns all products for manager" do
        get "/api/v1/products", headers: auth_headers(manager)
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.size).to eq(3)
      end

      it "returns all products for staff" do
        get "/api/v1/products", headers: auth_headers(staff)
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.size).to eq(3)
      end

      it "includes components for bundle products" do
        get "/api/v1/products", headers: auth_headers(admin)
        json = JSON.parse(response.body)
        bundle = json.find { |p| p["is_bundle"] }
        expect(bundle["components"]).not_to be_empty
        expect(bundle["components"].map { |c| c["name"] }).to include("Coffee", "Tea")
      end
    end

    context "when user is unauthenticated" do
      it "returns 401 unauthorized" do
        get "/api/v1/products"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /show" do
    context "when user is authenticated" do
      it "returns the product details" do
        get "/api/v1/products/#{coffee.id}", headers: auth_headers(admin)
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["name"]).to eq("Coffee")
        expect(json["price"]).to eq("10.0")
      end

      it "returns 404 for non-existent product" do
        get "/api/v1/products/9999", headers: auth_headers(admin)
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Product not found")
      end
    end

    context "when user is unauthenticated" do
      it "returns 401 unauthorized" do
        get "/api/v1/products/#{coffee.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /create" do
    context "when user is admin or manager" do
      let(:valid_params) do
        {
          product: {
            name: "Diet Coke",
            price: 10
          }
        }.to_json
      end

      it "creates a new product" do
        post "/api/v1/products",
            headers: auth_headers(admin).merge({ "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json" }),
            params: valid_params

        puts "Response body****: #{response.body}"
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["product"]["name"]).to eq("Diet Coke")
      end
    end
  end
end
