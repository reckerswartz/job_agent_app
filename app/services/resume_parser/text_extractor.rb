module ResumeParser
  class TextExtractor < Base
    def extract_text
      blob = profile.source_document.blob
      blob.open do |tempfile|
        tempfile.read.force_encoding("UTF-8")
      end
    rescue => e
      Rails.logger.error("[ResumeParser::TextExtractor] Failed to read text file: #{e.message}")
      nil
    end
  end
end
