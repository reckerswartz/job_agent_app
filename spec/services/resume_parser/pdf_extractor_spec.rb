require "rails_helper"

RSpec.describe ResumeParser::PdfExtractor do
  describe "#extract_text" do
    it "extracts text from a PDF file" do
      profile = create(:profile)
      profile.source_document.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/sample_resume.pdf")),
        filename: "sample_resume.pdf",
        content_type: "application/pdf"
      )

      extractor = described_class.new(profile)
      text = extractor.extract_text

      expect(text).to be_present
      expect(text).to be_a(String)
      expect(text.length).to be > 50
    end

    it "returns nil for malformed PDF" do
      profile = create(:profile)
      profile.source_document.attach(
        io: StringIO.new("not a real pdf"),
        filename: "bad.pdf",
        content_type: "application/pdf"
      )

      extractor = described_class.new(profile)
      expect(extractor.extract_text).to be_nil
    end
  end
end
