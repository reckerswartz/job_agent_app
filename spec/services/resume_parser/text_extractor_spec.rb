require "rails_helper"

RSpec.describe ResumeParser::TextExtractor do
  describe "#extract_text" do
    it "extracts text from a text file" do
      profile = create(:profile)
      profile.source_document.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/sample_resume.txt")),
        filename: "sample_resume.txt",
        content_type: "text/plain"
      )

      extractor = described_class.new(profile)
      text = extractor.extract_text

      expect(text).to be_present
      expect(text).to include("Pankaj Kumar")
      expect(text).to include("Senior Ruby on Rails Developer")
    end
  end
end
