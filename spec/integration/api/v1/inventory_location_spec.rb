# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'API::V1::InventoryLocations', type: :request do
  let(:user) { User.create!(name: "Manager", email: "manager@example.com", password: "password", role: :staff) }
  let(:auth_token) { auth_headers(user)["Authorization"] }

  let(:warehouse) { Warehouse.create!(name: "Main Warehouse", address: "123 Street") }
  let!(:location1) { InventoryLocation.create!(storage_id: "BIN-01", warehouse: warehouse, capacity: 500) }
  let!(:location2) { InventoryLocation.create!(storage_id: "BIN-02", warehouse: warehouse, capacity: 300) }

  let(:product) { Product.create!(name: "Test Product", brand: "LV", price: 20.0, created_by_user: user) }
  let(:status) { InventoryStatus.create!(name: "Sellable") }
  let!(:inventory_summary) do
    InventorySummary.create!(
      product: product,
      inventory_location: location1,
      inventory_status: status,
      quantity_on_hand: 10,
      reserved_quantity: 2
    )
  end

  path '/api/v1/inventory_locations/by_warehouse' do
    get('Get inventory locations by warehouse') do
      tags 'InventoryLocations'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :warehouse_id, in: :query, type: :integer, description: 'Warehouse ID'

      response(200, 'successful') do
        let(:Authorization) { auth_token }
        let(:warehouse_id) { warehouse.id }

        run_test! do |response|
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json["locations"].length).to eq(2)
          puts "JSON Response: #{json}"
          expect(json["locations"].first).to have_key('id')
          expect(json["locations"].first).to have_key('storage_id')
        end
      end

      response(400, 'bad request') do
        let(:Authorization) { auth_token }
        let(:warehouse_id) { nil }
        run_test! do |response|
          expect(response).to have_http_status(:bad_request)
          json = JSON.parse(response.body)
          expect(json["error"]).to eq("warehouse_id parameter is required")
        end
      end
    end
  end

  path '/api/v1/inventory_locations/{id}' do
    get('Show inventory details for a location') do
      tags 'InventoryLocations'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :id, in: :path, type: :integer, description: 'Inventory Location ID'

      response(200, 'successful') do
        let(:Authorization) { auth_token }
        let(:id) { location1.id }

        run_test! do |response|
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json["location"]["id"]).to eq(location1.id)
          expect(json["inventory_details"].first["name"]).to eq(product.name)
          expect(json["inventory_details"].first["quantity_on_hand"]).to eq(inventory_summary.quantity_on_hand)
        end
      end

      response(404, 'not found') do
        let(:Authorization) { auth_token }
        let(:id) { 999 }
        run_test! do |response|
          expect(response).to have_http_status(:not_found)
          json = JSON.parse(response.body)
          expect(json["error"]).to eq("Inventory Location not found")
        end
      end
    end
  end

  path '/api/v1/inventory_locations/{id}/history' do
    get('Get inventory history for a location') do
      tags 'InventoryLocations'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :id, in: :path, type: :integer, description: 'Inventory Location ID'

      response(200, 'successful') do
        let(:Authorization) { auth_token }
        let(:id) { location1.id }

        run_test! do |response|
          expect(response).to have_http_status(:ok)
          # Further assertions can be added here once the history endpoint is implemented
        end
      end

      response(404, 'not found') do
        let(:Authorization) { auth_token }
        let(:id) { 999 }
        run_test! do |response|
          expect(response).to have_http_status(:not_found)
          json = JSON.parse(response.body)
          expect(json["error"]).to eq("Inventory Location not found")
        end
      end
    end
  end
end
