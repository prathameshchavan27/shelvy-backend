class HealthController < ActionController::API
  def show
    checks = {
      database: database_connected?,
      redis: redis_connected?
    }

    status = checks.values.all? ? :ok : :service_unavailable

    render json: {
      status: status == :ok ? "healthy" : "unhealthy",
      timestamp: Time.current.iso8601,
      checks: checks
    }, status: status
  end

  private

  def database_connected?
    ActiveRecord::Base.connection.execute("SELECT 1")
    true
  rescue StandardError
    false
  end

  def redis_connected?
    return true unless defined?(Sidekiq)

    Sidekiq.redis(&:ping) == "PONG"
  rescue StandardError
    false
  end
end
