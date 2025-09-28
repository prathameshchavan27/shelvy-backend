class Api::V1::Users::SessionsController < Devise::SessionsController
  respond_to :json

  # Called on successful login
  private
  def respond_with(resource, _opts = {})
    render json: {
      status: { code: 200, message: "Logged in successfully." },
      data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
    }, status: :ok
  end

  # Called on logout
  def respond_to_on_destroy
    if current_user
      render json: { status: { code: 200, message: "Logged out successfully." } }, status: :ok
    else
      render json: { status: { code: 401, message: "Couldn't find an active session." } }, status: :unauthorized
    end
  end

  # Called on failed login
  def respond_to_on_failed_login
    render json: { errors: [ "Invalid email or password" ] }, status: :unauthorized
  end
end
