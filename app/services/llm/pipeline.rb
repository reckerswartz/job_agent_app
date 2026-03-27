module Llm
  class Pipeline
    def initialize(provider = nil)
      @provider = provider || LlmProvider.active.find(&:available?)
    end

    def available?
      provider.present? && provider.available?
    end

    def vision_model
      @vision_model ||= provider&.llm_models&.active&.by_role("primary_vision")&.first ||
                         provider&.llm_models&.active&.vision_capable&.first
    end

    def text_model
      @text_model ||= provider&.llm_models&.active&.by_role("primary_text")&.first ||
                       provider&.llm_models&.active&.text_capable&.first
    end

    def verification_model
      @verification_model ||= provider&.llm_models&.active&.by_role("verification")&.first
    end

    def client
      @client ||= Llm::Client.new(provider)
    end

    private

    attr_reader :provider
  end
end
