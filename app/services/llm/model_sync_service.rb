module Llm
  class ModelSyncService
    def initialize(provider)
      @provider = provider
    end

    def sync!
      return { error: "Provider not available" } unless provider.available?

      models_data = fetch_models
      return { error: "Failed to fetch models from API" } if models_data.nil?

      added = 0
      updated = 0
      api_identifiers = []

      models_data.each do |m|
        id_str = m["id"]
        next if id_str.blank?

        api_identifiers << id_str
        model = provider.llm_models.find_or_initialize_by(identifier: id_str)
        was_new = model.new_record?

        model.name = derive_name(id_str, m)
        model.model_type = derive_type(m)
        model.supports_text = model.model_type.in?(%w[text multimodal])
        model.supports_vision = model.model_type.in?(%w[vision multimodal])
        model.active = true if was_new
        model.context_window = m.dig("context_length") || m.dig("max_model_len")
        model.owned_by = m["owned_by"].presence || id_str.split("/").first

        model.save!
        was_new ? added += 1 : updated += 1
      end

      deactivated = provider.llm_models.where.not(identifier: api_identifiers).update_all(active: false)

      Rails.logger.info("[ModelSyncService] Synced: #{added} added, #{updated} updated, #{deactivated} deactivated")
      { added: added, updated: updated, deactivated: deactivated, total: api_identifiers.size }
    end

    private

    attr_reader :provider

    def fetch_models
      uri = URI("#{provider.base_url}/models")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.read_timeout = 30
      http.open_timeout = 15

      request = Net::HTTP::Get.new(uri.path)
      request["Authorization"] = "Bearer #{provider.api_key}"
      request["Content-Type"] = "application/json"

      response = http.request(request)

      if response.code.to_i == 200
        body = JSON.parse(response.body)
        body["data"] || []
      else
        Rails.logger.error("[ModelSyncService] API returned #{response.code}: #{response.body.to_s.truncate(500)}")
        nil
      end
    rescue => e
      Rails.logger.error("[ModelSyncService] Failed: #{e.message}")
      nil
    end

    def derive_name(identifier, data)
      data["name"].presence ||
        identifier.split("/").last.gsub("-", " ").gsub("_", " ").titleize.truncate(100)
    end

    def derive_type(data)
      owned_by = data["owned_by"].to_s.downcase
      id_str = data["id"].to_s.downcase

      if id_str.include?("vision") || id_str.include?("vlm")
        "vision"
      elsif id_str.include?("multimodal") || id_str.include?("maverick")
        "multimodal"
      else
        "text"
      end
    end
  end
end
