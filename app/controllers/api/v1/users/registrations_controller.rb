# frozen_string_literal: true

class Api::V1::Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  def create
    build_resource(sign_up_params)
    resource.save
    respond_with resource
  end

  private

  # Permit the custom 'name' attribute for sign up
  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        status: { code: 201, message: "Signed up sucessfully." },
        data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
      }, status: :created
    else
      render json: {
        status: { code: 422,  message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}" }
      }, status: :unprocessable_entity
    end
  end
end
