require 'rails_helper'

RSpec.describe "User Sessions", type: :request do
    describe "POST /api/v1/login" do
        let(:user) { create(:user) }

        context "with valid params" do
            let(:valid_params) do
            {
                user: {
                    email: user.email,
                    password: user.password
                }
            }
            end

            it "logs in the user" do
                post "/api/v1/login", params: valid_params
                expect(response).to have_http_status(:ok)
                json = JSON.parse(response.body)
                expect(json["data"]["email"]).to eq(user.email)
            end
        end

        context "with invalid params" do
            let(:invalid_params) do
            {
                user: {
                    email: user.email,
                    password: "wrongpassword"
                }
            }
            end

            it "does not log in the user" do
                post "/api/v1/login", params: invalid_params

                expect(response).to have_http_status(:unauthorized)
                expect(response.body.strip).to eq("Invalid email or password.")
            end
        end
    end
end
