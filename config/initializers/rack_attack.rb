class Rack::Attack
  ### Configure Cache ###
  # Use Rails cache for storing rate limit data
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Disable rate limiting in test environment
  Rack::Attack.enabled = !Rails.env.test?

  ### Throttle Strategies ###

  # Throttle all requests by IP (60 requests per minute)
  throttle("req/ip", limit: 60, period: 1.minute) do |req|
    req.ip unless req.path.start_with?("/assets", "/health")
  end

  # Throttle login attempts by IP (5 attempts per 20 seconds)
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    if req.path == "/api/v1/login" && req.post?
      req.ip
    end
  end

  # Throttle login attempts by email (5 attempts per minute)
  throttle("logins/email", limit: 5, period: 1.minute) do |req|
    if req.path == "/api/v1/login" && req.post?
      req.params.dig("user", "email")&.downcase&.strip
    end
  end

  # Throttle signup attempts (3 per minute per IP)
  throttle("signups/ip", limit: 3, period: 1.minute) do |req|
    if req.path == "/api/v1/signup" && req.post?
      req.ip
    end
  end

  # Throttle inventory write operations (30 per minute)
  throttle("inventory_writes/ip", limit: 30, period: 1.minute) do |req|
    if req.post? || req.patch? || req.put? || req.delete?
      req.ip
    end
  end

  ### Custom Responses ###

  self.throttled_responder = lambda do |request|
    retry_after = (request.env["rack.attack.match_data"] || {})[:period]
    [
      429,
      {
        "Content-Type" => "application/json",
        "Retry-After" => retry_after.to_s
      },
      [{ error: "Rate limit exceeded. Retry later.", retry_after: retry_after }.to_json]
    ]
  end

  ### Safelist ###

  # Allow all requests from localhost in development
  safelist("allow-localhost") do |req|
    req.ip == "127.0.0.1" || req.ip == "::1" if Rails.env.development?
  end
end
