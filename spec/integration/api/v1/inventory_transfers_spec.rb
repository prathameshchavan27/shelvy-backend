require 'rails_helper'
require 'swagger_helper'

RSpec.describe Api::V1::InventoryTransfersController, type: :request do
  let(:user) { User.create!(name: "Manager", email: "manager@example.com", password: "password") }
  let(:auth_token) { auth_headers(user)["Authorization"] }
  let(:warehouse) { Warehouse.create!(name: "Main Warehouse", address: "123 Warehouse St") }
  let(:location) { InventoryLocation.create!(storage_id: "BIN-01", warehouse: warehouse) }
  let(:sellable) { InventoryStatus.create!(name: "Sellable") }
  let(:product) { Product.create!(name: "Sample Product", price: 20, created_by_user: user) }
  let(:inventory_summary1) { InventorySummary.create!(product: product, inventory_location: location, inventory_status: sellable, quantity_on_hand: 10, reserved_quantity: 0) }
  let(:inventory_summary2) { InventorySummary.create!(product: product, inventory_location: location, inventory_status: sellable, quantity_on_hand: 5, reserved_quantity: 0) }
  # -----------------------------
  # GET /locations_to_transfer
  # -----------------------------
  path '/api/v1/inventory_transfers/locations_to_transfer' do
    get('Get locations to transfer inventory to') do
      tags 'InventoryTransfers'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :warehouse_id, in: :query, type: :integer, description: 'Warehouse ID'

      response(200, 'successful') do
        let(:Authorization) { auth_token }
        let(:warehouse_id) { warehouse.id }

        # 🔥 FORCE DATA CREATION
        before do
          location
        end

        run_test! do |response|
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)

          expect(json["locations"]).to be_an(Array)
          expect(json["locations"]).not_to be_empty
          expect(json["locations"].first).to have_key("storage_id")
        end
      end
    end
  end

  # -----------------------------
  # POST /transfer_inventory
  # -----------------------------
  path '/api/v1/inventory_transfers/transfer_inventory' do
    post('Transfer inventory between locations') do
      tags 'InventoryTransfers'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]

      # ✅ BODY PARAMETER MUST HAVE A NAME
      parameter name: :transfer_params, in: :body, schema: {
        type: :object,
        properties: {
            transfer_params: {
            type: :object,
            properties: {
                source_location_id: { type: :integer },
                destination_location_id: { type: :integer },
                items: {
                type: :object,
                additionalProperties: {
                    type: :object,
                    properties: {
                    quantity: { type: :integer }
                    },
                    required: [ 'quantity' ]
                }
                }
            },
            required: [ 'source_location_id', 'destination_location_id', 'items' ]
            }
        },
        required: [ 'transfer_params' ]
      }


      response(200, 'successful') do
        let(:Authorization) { auth_token }

        let(:source_location) do
          InventoryLocation.create!(storage_id: "BIN-01", warehouse: warehouse)
        end

        let(:destination_location) do
          InventoryLocation.create!(storage_id: "BIN-02", warehouse: warehouse)
        end

        # 🔥 MUST MATCH parameter name
        let(:transfer_params) do
        {
            transfer_params: {
                source_location_id: source_location.id,
                destination_location_id: destination_location.id,
                items: {
                    inventory_summary1.id => { quantity: 2 },
                    inventory_summary2.id => { quantity: 1 }
                }
            }
        }
        end


        run_test! do |response|
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json["message"]).to eq(
            "Inventory transferred to #{destination_location.id}"
          )
        end
      end
    end
  end
end
