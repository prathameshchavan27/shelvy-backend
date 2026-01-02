require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'API::V1::Receivings', type: :request do
  let(:admin) { User.create!(name: "Admin", email: "admin@example.com", password: "password") }
  let(:auth_token) { auth_headers(admin)["Authorization"] }
  let(:warehouse) { Warehouse.create!(name: "Main Warehouse", address: "123 Street") }
  let(:product) { Product.create!(name: 'Coffee', sku: 'COF-01', brand: 'ajsd', barcode: '12345678', price: 10, created_by_user: admin) }
  let(:bin1) { InventoryLocation.create!(storage_id: "BIN-03", warehouse: warehouse, capacity: 100, unique_item_limits: 5) }

  # This is the critical line to fix the "undefined method id for nil" error
  let!(:sellable_status) { InventoryStatus.create!(name: "Sellable") }

  path '/api/v1/receivings/receive_inventory' do
    post('Receive inventory') do
      tags 'Receiving'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          receiving: {
            type: :object,
            properties: {
              product_id: { type: :integer },
              location_id: { type: :integer },
              quantity: { type: :integer }
            },
            required: %w[product_id location_id quantity]
          }
        },
        required: [ 'receiving' ]
      }

      response(200, 'successful') do
        let(:Authorization) { auth_token }
        let(:params) do
          {
            receiving: {
              product_id: product.id,
              location_id: bin1.id,
              quantity: 10
            }
          }
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['message']).to eq("Inventory received successfully")
        end
      end

      response(422, 'unprocessable entity') do
        let(:Authorization) { auth_token }
        let(:params) do
          {
            receiving: {
              product_id: product.id,
              location_id: bin1.id,
              quantity: 10000
            }
          }
        end
        run_test!
      end
    end
  end
end
