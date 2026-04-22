# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # IMPORTANT: Set CORS_ORIGINS in production (e.g., "https://app.example.com")
    # Never use "*" in production as it allows requests from any origin
    if Rails.env.production?
      origins ENV.fetch("CORS_ORIGINS") { raise "CORS_ORIGINS must be set in production" }.split(",")
    else
      origins ENV.fetch("CORS_ORIGINS", "http://localhost:3000,http://localhost:5173").split(",")
    end

    resource "*",
      headers: :any,
      expose: ["Authorization"],
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      max_age: 86400
  end
end
