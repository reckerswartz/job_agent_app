module ResumeParser
  class PdfExtractor < Base
    def extract_text
      blob = profile.source_document.blob
      blob.open do |tempfile|
        reader = PDF::Reader.new(tempfile.path)
        reader.pages.map(&:text).join("\n\n")
      end
    rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError => e
      Rails.logger.error("[ResumeParser::PdfExtractor] Failed to parse PDF: #{e.message}")
      nil
    end
  end
end
