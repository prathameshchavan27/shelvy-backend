require 'rails_helper'

RSpec.describe "User Registration", type: :request do
  describe "POST /api/v1/signup" do
    context "with valid params" do
      let(:valid_params) do
        {
          user: {
            email: "newuser@example.com",
            name: "New User",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      it "creates a new user" do
        expect {
          post "/api/v1/signup", params: valid_params
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body)
        expect(json["data"]["email"]).to eq("newuser@example.com")
        expect(json["data"]["name"]).to eq("New User")
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        {
          user: {
            email: "invalid-email",
            name: "x",
            password: "123",
            password_confirmation: "456"
          }
        }
      end

      it "does not create a user" do
        expect {
          post "/api/v1/signup", params: invalid_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json["status"]).to be_present
      end
    end
  end
end
