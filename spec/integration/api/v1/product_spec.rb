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
      consumes 'application/json'
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
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :id, in: :path, type: :string

      response(200, 'successful') do
        let(:Authorization) { auth_token }
        let(:id) { Product.create!(name: 'Coffee', brand: 'Starbucks', price: 10, created_by_user: admin).id }

        run_test!
      end

      response(404, 'not found') do
        let(:Authorization) { auth_token }
        let(:id) { '999' }

        run_test!
      end
    end
  end


  path '/api/v1/products' do
    post('Create a product') do
      tags 'Products'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          product: {
            type: :object,
            properties: {
              name: { type: :string },
              brand: { type: :string },
              price: { type: :number }
            },
            required: %w[name brand price]
          }
        },
        required: [ 'product' ]
      }

      response(201, 'bundle created') do
        let(:Authorization) { auth_token }
        let(:coffee) { Product.create!(name: "Coffee", brand: "Starbucks", price: 10, created_by_user: admin) }
        let(:tea) { Product.create!(name: "Tea", brand: "Yogi", price: 8, created_by_user: admin) }
        let(:product) do
          {
            product: {
              name: 'Breakfast Combo',
              brand: "House",
              price: 25,
              is_bundle: true,
              component_ids: [ coffee.id, tea.id ],
              components: [
                { name: 'Muffin', brand: "Test", price: 5 }
              ]
            }
          }
        end

        run_test! do |response|
          expect(response).to have_http_status(:created)
          json = JSON.parse(response.body)
          puts "Response body Bundle: #{response.body}"
          expect(json["product"]['name']).to eq('Breakfast Combo')
          expect(json["product"]['is_bundle']).to be true
          expect(json["product"]["components"].size).to eq(3)
        end
      end

      response(201, 'created') do
        let(:Authorization) { auth_token }
        let(:product) do
          {
            product: {
              name: 'Coca Cola',
              brand: 'Coke',
              price: 15
            }
          }
        end

        run_test! do |response|
          expect(response).to have_http_status(:created)
          json = JSON.parse(response.body)
          puts "Response body: #{response.body}"
          expect(json["product"]['name']).to eq('Coca Cola')
          expect(json["product"]['price']).to eq("15.0")
        end
      end

      response(422, 'unprocessable entity') do
        let(:Authorization) { auth_token }
        let(:product) do
          {
            product: {
              name: '',
              brand: nil,
              price: nil
            }
          }
        end

        run_test! do |response|
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
  path '/api/v1/products/{id}' do
    patch('Update a product') do
      tags 'Products'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :id, in: :path, type: :string, description: 'Product ID'
      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          product: {
            type: :object,
            properties: {
              name: { type: :string },
              brand: { type: :string },
              price: { type: :number }
            }
          }
        },
        required: [ 'product' ]
      }

      response(200, 'updated') do
        let(:Authorization) { auth_token }
        let(:coffee) { Product.create!(name: "Coffee", brand: 'Test', price: 10, created_by_user: admin) }
        let(:id) { coffee.id }
        let(:product) do
          {
            product: {
              name: 'Updated Coffee',
              brand: 'Star',
              price: 12
            }
          }
        end

        run_test! do |response|
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          puts "Response body Update: #{response.body}"
          expect(json["product"]['name']).to eq('Updated Coffee')
          expect(json["product"]['price']).to eq("12.0")
        end
      end
    end
  end
end
