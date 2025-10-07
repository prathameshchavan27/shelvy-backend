module AuthHelpers
  # Returns headers including Authorization for a given user
  def auth_headers(user)
    # Warden JWT encoder from devise-jwt
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    {
      'Authorization' => "Bearer #{token}",
      'Content-Type' => 'application/json'
    }
  end
end
