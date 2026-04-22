Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.base_controller_class = "ActionController::API"

  # Use JSON format for easier parsing by log aggregators
  config.lograge.formatter = Lograge::Formatters::Json.new

  # Add custom data to each log entry
  config.lograge.custom_options = lambda do |event|
    {
      request_id: event.payload[:request_id],
      user_id: event.payload[:user_id],
      ip: event.payload[:ip],
      time: Time.current.iso8601
    }
  end

  # Include custom payload from controllers
  config.lograge.custom_payload do |controller|
    {
      request_id: controller.request.request_id,
      user_id: controller.current_user&.id,
      ip: controller.request.remote_ip
    }
  end

  # Keep original Rails logs in development for debugging
  config.lograge.keep_original_rails_log = Rails.env.development?

  # Ignore certain paths from logs
  config.lograge.ignore_actions = ["HealthController#show"]
end
