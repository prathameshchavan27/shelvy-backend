require 'rails_helper'

RSpec.describe "API::V1::InventoryLocations", type: :request do
  let(:user) { User.create!(name: "Tester", email: "tester@example.com", password: "password", role: "staff") }
  let(:warehouse) { Warehouse.create!(name: "Main Warehouse", address: "Pune") }
  let!(:location1) { InventoryLocation.create!(storage_id: "BIN-01", warehouse: warehouse, capacity: 300) }
  let!(:location2) { InventoryLocation.create!(storage_id: "BIN-02", warehouse: warehouse, capacity: 500) }

  let(:status) { InventoryStatus.create!(name: "Sellable") }
  let(:product) { Product.create!(name: "Laptop", price: 1000, created_by_user: user) }
  let!(:summary) do
    InventorySummary.create!(
      product: product,
      inventory_location: location1,
      inventory_status: status,
      quantity_on_hand: 10,
      reserved_quantity: 2
    )
  end


  describe "GET /api/v1/inventory_locations/by_warehouse" do
    context "when warehouse_id is provided" do
      it "returns the locations for that warehouse" do
        get "/api/v1/inventory_locations/by_warehouse", headers:  auth_headers(user), params: { warehouse_id: warehouse.id }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["locations"]).to be_an(Array)
        expect(json["locations"].size).to eq(2)
        expect(json["locations"].first.keys).to include("id", "storage_id")
      end
    end

    context "when warehouse_id is missing" do
      it "returns a bad request error" do
        get "/api/v1/inventory_locations/by_warehouse", headers: auth_headers(user)

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("warehouse_id parameter is required")
      end
    end
  end

  describe "GET /api/v1/inventory_locations/:id" do
    context "when location exists" do
      it "returns inventory details for that location" do
        get "/api/v1/inventory_locations/#{location1.id}", headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        puts "Response body: #{response.body}"
        expect(json["location"]["storage_id"]).to eq("BIN-01")
        expect(json["inventory_details"]).to be_an(Array)
        expect(json["inventory_details"].first["name"]).to eq("Laptop")
      end
    end

    context "when location does not exist" do
      it "returns not found" do
        get "/api/v1/inventory_locations/999999", headers: auth_headers(user)

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Inventory Location not found")
      end
    end
  end
end
