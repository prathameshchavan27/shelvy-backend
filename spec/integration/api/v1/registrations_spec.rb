# spec/integration/api/v1/auth/registrations_spec.rb
require 'swagger_helper'

RSpec.describe 'API V1 - User Registration', type: :request do
  path '/api/v1/signup' do
    post 'Registers a new user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
            user: {
            type: :object,
            properties: {
                name: { type: :string },
                email: { type: :string },
                password: { type: :string },
                password_confirmation: { type: :string }
            },
            required: %w[name email password password_confirmation]
            }
        },
        required: [ 'user' ]
      }

      response '201', 'User registered successfully' do
        let(:user) { { user: { name: 'John Doe', email: 'john@example.com', password: 'password', password_confirmation: 'password' } } }

        run_test!
      end

      response '400', 'Validation error' do
        let(:user) { { email: 'invalid@example.com' } }
        run_test!
      end
    end
  end
end
