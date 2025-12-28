require 'rails_helper'
require 'swagger_helper'

RSpec.describe Api::V1::InventoryLocationsController, type: :request do
  let(:user) { User.create!(name: "Manager", email: "manager@example.com", password: "password", role: :manager) }
  let(:auth_token) { auth_headers(user)["Authorization"] }
  let(:warehouse) { Warehouse.create!(name: "Main Warehouse", address: "123 Warehouse St") }
  let(:location) { InventoryLocation.create!(storage_id: "BIN-01", warehouse: warehouse) }
  let(:sellable) { InventoryStatus.create!(name: "Sellable") }

  # Setup Bundle and Component
  let(:component) { Product.create!(name: "Individual Sock", brand: "Adidas", sku: "SOCK-1", price: 5, created_by_user: user) }
  let(:bundle) { Product.create!(name: "Socks 3-pack", brand: "Adidas", sku: "SOCK-BUN", price: 12, is_bundle: true, case_pack_qty: 3, created_by_user: user) }

  let!(:inventory_summary) do
    # Link component to bundle via your association (e.g., product_components table)
    bundle.components << component

    # Add initial bundle stock to the location
    InventorySummary.create!(
      product: bundle,
      inventory_location: location,
      inventory_status: sellable,
      quantity_on_hand: 5,
      reserved_quantity: 0
    )
  end

  # -----------------------------
  # POST /unbundle
  # -----------------------------
  path '/api/v1/unbundles/unbundle' do
    post('Unbundle a product into its components') do
      tags 'Inventory Transformations'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :unbundle_params, in: :body, schema: {
        type: :object,
        properties: {
          unbundle: {
            type: :object,
            properties: {
              bundle_product_id: { type: :integer, description: 'ID of the bundle product' },
              inventory_location_id: { type: :integer, description: 'ID of the location/bin' },
              quantity: { type: :integer, description: 'Number of bundles to unpack' }
            },
            required: [ 'product_id', 'inventory_location_id', 'quantity' ]
          }
        },
        required: [ 'unbundle' ]
      }

      response(200, 'successful') do
        let(:Authorization) { auth_token }

        let(:unbundle_params) do
          {
            unbundle: {
              bundle_product_id: bundle.id,
              inventory_location_id: location.id,
              quantity: 2
            }
          }
        end

        run_test! do |response|
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)

          expect(json["message"]).to include("successfully unbundled")

          # Verify database changes
          inventory_summary.reload
          expect(inventory_summary.quantity_on_hand).to eq(3) # 5 - 2

          component_summary = InventorySummary.find_by(product: component, inventory_location: location)
          expect(component_summary.quantity_on_hand).to eq(6) # 2 bundles * 3 case_pack_qty
        end
      end

      response(422, 'insufficient inventory') do
        let(:Authorization) { auth_token }
        let(:unbundle_params) do
          {
            unbundle: {
              bundle_product_id: bundle.id,
              inventory_location_id: location.id,
              quantity: 100 # Way more than the 5 we created
            }
          }
        end

        run_test! do |response|
          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["error"]).to eq("Unbundling failed, Not enough inventory to unbundle")
        end
      end
    end
  end
end
