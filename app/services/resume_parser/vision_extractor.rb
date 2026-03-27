module ResumeParser
  class VisionExtractor < Base
    PROMPT = "Extract all text from this resume image. Return the plain text content exactly as it appears, preserving structure and formatting. Do not summarize or interpret — just extract the raw text."

    def extract_text
      client = Llm::Client.for_feature("resume_parse", vision: true)
      return nil unless client

      blob = profile.source_document.blob
      blob.open do |tempfile|
        image_data = "data:#{blob.content_type};base64,#{Base64.strict_encode64(tempfile.read)}"
        result = client.vision(
          image_data,
          prompt: PROMPT,
          user: profile.user,
          profile: profile,
          feature: "resume_parse"
        )
        result[:content]
      end
    rescue => e
      Rails.logger.error("[ResumeParser::VisionExtractor] Failed: #{e.message}")
      nil
    end
  end
end
