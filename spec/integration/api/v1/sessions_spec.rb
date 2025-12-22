# spec/integration/api/v1/auth/sessions_spec.rb
require 'swagger_helper'

RSpec.describe 'API V1 - User Login', type: :request do
  path '/api/v1/login' do
    post 'Logs in an existing user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
            user: {
            type: :object,
            properties: {
                email: { type: :string },
                password: { type: :string }
            },
            required: %w[email password]
            }
        },
        required: %w[email password]
      }

      response '200', 'User logged in successfully' do
        let(:user) { User.create!(name: 'John', email: 'john@example.com', password: 'password') }
        let(:credentials) do
        {
            user: {
            email: user[:email],
            password: 'password'
            }
        }
        end

        # Ensure params are sent as JSON
        run_test! do |response|
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          token = response.headers['Authorization'].split(' ').last
          expect(json['data']['email']).to eq(user.email)
          expect(token).to be_present
        end
      end

      response '401', 'Invalid credentials' do
        let(:credentials) { { email: 'john@example.com', password: 'wrong' } }

        run_test! do |response|
          expect(response).to have_http_status(:unauthorized)
          json = JSON.parse(response.body)
          expect(json['error']).to eq('You need to sign in or sign up before continuing.')
        end
      end
    end
  end
end
