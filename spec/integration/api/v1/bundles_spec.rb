require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::V1::Bundles', type: :request do
  let(:user) { User.create!(name: "Manager", email: "manager@example.com", password: "password", role: :manager) }
  let(:auth_token) { auth_headers(user)["Authorization"] }
  let(:warehouse) { Warehouse.create!(name: "Main Warehouse", address: "123 Warehouse St") }
  let(:location) { InventoryLocation.create!(storage_id: "BIN-01", warehouse: warehouse) }
  let(:sellable) { InventoryStatus.create!(name: "Sellable") }

  # Setup Bundle and Component
  let(:component) { Product.create!(name: "Individual Sock", brand: "Adidas", sku: "SOCK-1", price: 5, created_by_user: user) }
  let(:bundle) { Product.create!(name: "Socks 3-pack", brand: "Adidas", sku: "SOCK-BUN", price: 12, is_bundle: true, case_pack_qty: 3, created_by_user: user) }

  before do
    bundle.components << component
    # Add initial component stock
    InventorySummary.create!(
      product: component,
      inventory_location: location,
      inventory_status: sellable,
      quantity_on_hand: 10,
      reserved_quantity: 0
    )
  end

  path '/api/v1/bundles/{id}/bundling_availability' do
    get('Get maximum possible bundles based on component stock in single bins') do
      tags 'Inventory Transformations'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :id, in: :path, type: :integer, description: 'ID of the Bundle Product'
      parameter name: :warehouse_id, in: :query, type: :integer, description: 'ID of the Warehouse to check'

      response(200, 'successful') do
        let(:Authorization) { auth_token }
        let(:id) { bundle.id }
        let(:warehouse_id) { warehouse.id }

        run_test! do |response|
          json = JSON.parse(response.body)

          expect(json).to have_key('max_bundlable_qty')
          expect(json).to have_key('source_bins')
          expect(json['bundle_id']).to eq(bundle.id)

          # In our test setup, we have 10 socks.
          # Assuming 1 sock per bundle, max should be 10.
          expect(json['max_bundlable_qty']).to eq(10)

          # Verify source bin details
          source_bin = json['source_bins'].first
          expect(source_bin['sku']).to eq(component.sku)
          expect(source_bin['best_location_id']).to eq(location.id)
          expect(source_bin['available_in_bin']).to eq(10)
        end
      end

      response(404, 'bundle not found') do
        let(:Authorization) { auth_token }
        let(:id) { 999999 }
        let(:warehouse_id) { warehouse.id }
        run_test!
      end
    end
  end

  path '/api/v1/bundles/bundle_inventory' do
    post('Execute Bundling Transformation') do
      tags 'Inventory Transformations'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :bundle_request, in: :body, schema: {
        type: :object,
        properties: {
          bundle: {
            type: :object,
            properties: {
              bundle_product_id: { type: :integer },
              destination_location_id: { type: :integer },
              quantity_to_create: { type: :integer },
              components: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    product_id: { type: :integer },
                    inventory_location_id: { type: :integer },
                    quantity_per_bundle: { type: :integer }
                  },
                  required: [ 'product_id', 'inventory_location_id', 'quantity_per_bundle' ]
                }
              }
            },
            required: [ 'bundle_product_id', 'destination_location_id', 'quantity_to_create', 'components' ]
          }
        },
        required: [ 'bundle' ]
      }

      response(200, 'successful') do
        let(:Authorization) { auth_token }
        let(:bundle_request) do
          {
            bundle: {
              bundle_product_id: bundle.id,
              destination_location_id: location.id,
              quantity_to_create: 2,
              components: [
                {
                  product_id: component.id,
                  inventory_location_id: location.id,
                  quantity_per_bundle: 1
                }
              ]
            }
          }
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          #   expect(json["status"]).to eq("success")

          # Verify Immutable Ledger: Check that a new record was created
          # instead of just updating the old one
          latest_stock = InventorySummary.where(product: component).order(created_at: :desc).first
          expect(latest_stock.quantity_on_hand).to eq(8) # 10 - (2 * 1)
        end
      end

      response(422, 'failed transaction') do
        let(:Authorization) { auth_token }
        # Trigger failure by requesting more than available stock (10)
        let(:bundle_request) do
          {
            bundle: {
              bundle_product_id: bundle.id,
              destination_location_id: location.id,
              quantity_to_create: 50,
              components: [
                {
                  product_id: component.id,
                  inventory_location_id: location.id,
                  quantity_per_bundle: 1
                }
              ]
            }
          }
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          puts "++++++++++++++++#{json["errors"]}"
          expect(json["errors"].first).to include("Insufficient stock")
        end
      end
    end
  end
end
