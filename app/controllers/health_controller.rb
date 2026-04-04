class HealthController < ActionController::API
  def show
    checks = {
      status: "ok",
      database: check_database,
      llm: check_llm,
      models_active: LlmModel.active.count,
      users: User.count,
      listings: JobListing.count,
      uptime: format_uptime
    }

    checks[:status] = "degraded" if checks[:database] != "ok" || checks[:llm] == "unavailable"

    render json: checks, status: checks[:status] == "ok" ? :ok : :service_unavailable
  end

  private

  def check_database
    ActiveRecord::Base.connection.execute("SELECT 1")
    "ok"
  rescue => e
    "error: #{e.message.truncate(50)}"
  end

  def check_llm
    provider = LlmProvider.active.first
    provider&.available? ? "available" : "unavailable"
  rescue
    "unavailable"
  end

  def format_uptime
    seconds = (Time.current - Rails.application.config.app_start_time).to_i
    days = seconds / 86400
    hours = (seconds % 86400) / 3600
    "#{days}d #{hours}h"
  rescue
    "unknown"
  end
end
