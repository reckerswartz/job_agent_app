module Llm
  class ApiError < StandardError
    attr_reader :http_status, :provider_name, :model_identifier

    def initialize(message, http_status: nil, provider_name: nil, model_identifier: nil)
      @http_status = http_status
      @provider_name = provider_name
      @model_identifier = model_identifier
      super(message)
    end

    def user_friendly_message
      case http_status
      when 401 then "API key is invalid or expired. Please update it in Admin > API Keys."
      when 403 then "Access denied by the AI provider. Check your API key permissions."
      when 404 then "The AI model '#{model_identifier}' was not found. Try syncing models in Admin."
      when 429 then "Rate limit exceeded. Please try again in a moment."
      when 500, 502, 503 then "The AI service is temporarily unavailable. Please try again later."
      else "AI processing failed. The system will retry automatically."
      end
    end
  end
end
