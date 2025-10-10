# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'API::V1::Products', type: :request do
  let(:admin) { User.create!(name: "Admin", email: "admin@example.com", password: "password", role: :admin) }
  let(:auth_token) { auth_headers(admin)["Authorization"] } # use your auth_helper
  let(:warehouse) { Warehouse.create!(name: "Main Warehouse", address: "123 Street") }
  let(:inventory_location) { InventoryLocation.create!(storage_id: "BIN-03", warehouse: warehouse, capacity: 100, unique_item_limits: 5) }
  path '/api/v1/products' do
    get('List all products') do
      tags 'Products'
      produces 'application/json'
      security [ bearerAuth: [] ]

      response(200, 'successful') do
        let(:Authorization) { auth_token }
        run_test!
      end
    end
  end

  path '/api/v1/products/{id}' do
    get('Show a product') do
      tags 'Products'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :id, in: :path, type: :string, description: 'Product ID'

      response(200, 'successful') do
        let(:Authorization) { auth_token }
        let(:id) { Product.create!(name: 'Coffee', price: 10, created_by_user: admin, inventory_location: inventory_location).id }
        run_test!
      end

      response(404, 'not found') do
        let(:Authorization) { auth_token }
        let(:id) { '999' }
        run_test!
      end
    end
  end
end
