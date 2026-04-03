module Llm
  class Client
    def initialize(provider)
      @provider = provider
      @adapter = build_adapter(provider)
    end

    def self.for_feature(feature_name, vision: false)
      provider = LlmProvider.active.find(&:available?)
      return nil unless provider

      client = new(provider)
      # Pre-select model based on feature type
      if vision
        return nil unless provider.default_vision_model
      end
      client
    end

    def chat(messages, model: nil, user: nil, profile: nil, feature: "general")
      model ||= provider.default_text_model
      raise "No text model available for #{provider.name}" unless model

      interaction = create_interaction(user: user, profile: profile, feature: feature, model: model, prompt: messages.last&.dig(:content))

      begin
        result = adapter.chat(messages, model: model)
        interaction.mark_completed!(result[:content], result[:token_usage], result[:latency_ms])
        result
      rescue => e
        interaction.mark_failed!(e.message)

        # Try fallback model
        fallback = provider.fallback_text_models.where.not(id: model.id).first
        if fallback
          Rails.logger.warn("[Llm::Client] Primary model #{model.identifier} failed, trying fallback #{fallback.identifier}")
          fb_interaction = create_interaction(user: user, profile: profile, feature: feature, model: fallback, prompt: messages.last&.dig(:content))
          begin
            result = adapter.chat(messages, model: fallback)
            fb_interaction.mark_completed!(result[:content], result[:token_usage], result[:latency_ms])
            return result
          rescue => fb_e
            fb_interaction.mark_failed!(fb_e.message)
          end
        end

        raise
      end
    end

    def vision(image_data, prompt:, model: nil, user: nil, profile: nil, feature: "resume_parse")
      model ||= provider.default_vision_model
      raise "No vision model available for #{provider.name}" unless model

      interaction = create_interaction(user: user, profile: profile, feature: feature, model: model, prompt: prompt)

      begin
        result = adapter.vision(image_data, prompt: prompt, model: model)
        interaction.mark_completed!(result[:content], result[:token_usage], result[:latency_ms])
        result
      rescue => e
        interaction.mark_failed!(e.message)
        raise
      end
    end

    private

    attr_reader :provider, :adapter

    def build_adapter(provider)
      case provider.adapter
      when "nvidia" then NvidiaAdapter.new(provider)
      else raise "Unknown adapter: #{provider.adapter}"
      end
    end

    def create_interaction(user:, profile:, feature:, model:, prompt:)
      LlmInteraction.create!(
        user: user || User.first,
        profile: profile,
        llm_provider: provider,
        llm_model: model,
        feature_name: feature,
        prompt: prompt.to_s.truncate(10_000),
        status: "pending"
      )
    end
  end
end
