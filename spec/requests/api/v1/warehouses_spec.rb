require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Api::V1::Warehouses", type: :request do
  let(:staff) { User.create!(name: "Staff", email: "staff@example.com", password: "password", role: :staff) }

  describe "GET /index" do
    context "when user is authenticated" do
      it "returns all warehouses" do
        get "/api/v1/warehouses", headers: auth_headers(staff)
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["warehouses"]).to be_an(Array)
      end
    end
    context "when user is not authenticated" do
      it "returns unauthorized status" do
        get "/api/v1/warehouses"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /show" do
    context "when user is authenticated" do
      it "returns the warehouse" do
        warehouse = Warehouse.create!(name: "Test Warehouse", address: "Test Location")
        get "/api/v1/warehouses/#{warehouse.id}", headers: auth_headers(staff)
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["warehouse"]).to be_present
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized status" do
        warehouse = Warehouse.create!(name: "Test Warehouse", address: "Test Location")
        get "/api/v1/warehouses/#{warehouse.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
