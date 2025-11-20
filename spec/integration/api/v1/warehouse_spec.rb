require 'swagger_helper'
require 'rails_helper'

RSpec.describe 'API::V1::Warehouses', type: :request do
    let(:user) { User.create!(name: 'Staff', email: 'staff@example.com', password: 'password', role: :staff) }
    let(:auth_token) { auth_headers(user)["Authorization"] }
  path '/api/v1/warehouses' do
    get('List warehouses') do
      tags 'Warehouses'
      security [ bearerAuth: [] ]
      produces 'application/json'

      response(200, 'successful') do
        let(:Authorization) { auth_token }
        run_test!
      end

      response(401, 'unauthorized') do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end

  path '/api/v1/warehouses/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Warehouse ID'

    get('Show warehouse') do
      tags 'Warehouses'
      security [ bearerAuth: [] ]
      produces 'application/json'

      response(200, 'successful') do
        let(:Authorization) { auth_token }
        let(:id) { Warehouse.create!(name: 'Main Storage', address: 'Location 1').id }

        run_test!
      end

      response(404, 'not found') do
        let(:Authorization) { auth_token }
        let(:id) { 999 }

        run_test!
      end

      response(401, 'unauthorized') do
        let(:Authorization) { nil }
        let(:id) { Warehouse.create!(name: 'W1', address: 'Loc').id }
        run_test!
      end
    end
  end
end
