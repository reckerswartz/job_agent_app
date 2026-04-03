module Admin
  class ApiKeysController < BaseController
    def index
      @settings = AppSetting::KNOWN_KEYS.map do |key, meta|
        setting = AppSetting.find_or_initialize_by(key: key)
        setting.description ||= meta[:description]
        setting
      end
      @providers = LlmProvider.all.includes(:llm_models)
    end

    def update
      params[:settings]&.each do |key, value|
        next unless AppSetting::KNOWN_KEYS.key?(key)
        next if value.blank?
        AppSetting.set(key, value)
      end

      redirect_to admin_api_keys_path, notice: "API keys saved successfully."
    end

    def test_connection
      provider = LlmProvider.active.first
      unless provider&.available?
        redirect_to admin_api_keys_path, alert: "No active provider with API key configured."
        return
      end

      uri = URI("#{provider.base_url}/models")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 15
      http.open_timeout = 10

      request = Net::HTTP::Get.new(uri.path)
      request["Authorization"] = "Bearer #{provider.api_key}"
      response = http.request(request)

      if response.code.to_i == 200
        body = JSON.parse(response.body)
        count = body["data"]&.size || 0
        redirect_to admin_api_keys_path, notice: "Connection successful! #{count} models available from #{provider.name}."
      else
        redirect_to admin_api_keys_path, alert: "Connection failed: HTTP #{response.code}. Check your API key."
      end
    rescue => e
      redirect_to admin_api_keys_path, alert: "Connection failed: #{e.message}"
    end
  end
end
