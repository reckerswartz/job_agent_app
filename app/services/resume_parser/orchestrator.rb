module ResumeParser
  class Orchestrator
    PDF_CONTENT_TYPES = %w[application/pdf].freeze
    TEXT_CONTENT_TYPES = %w[text/plain text/rtf].freeze
    IMAGE_CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze

    def initialize(profile)
      @profile = profile
    end

    def call
      return unless profile.source_document.attached?

      content_type = profile.source_document.blob.content_type

      extracted_text = case content_type
      when *PDF_CONTENT_TYPES
        PdfExtractor.new(profile).extract_text
      when *TEXT_CONTENT_TYPES
        TextExtractor.new(profile).extract_text
      when *IMAGE_CONTENT_TYPES
        nil
      else
        Rails.logger.warn("[ResumeParser::Orchestrator] Unsupported content type: #{content_type}")
        nil
      end

      if extracted_text.present?
        profile.update!(source_text: extracted_text, source_mode: "upload")
      end

      extracted_text
    end

    private

    attr_reader :profile
  end
end
