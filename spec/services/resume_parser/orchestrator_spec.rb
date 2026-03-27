require "rails_helper"

RSpec.describe ResumeParser::Orchestrator do
  describe "#call" do
    it "extracts text from PDF and updates profile" do
      profile = create(:profile)
      profile.source_document.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/sample_resume.pdf")),
        filename: "resume.pdf",
        content_type: "application/pdf"
      )

      result = described_class.new(profile).call

      expect(result).to be_present
      profile.reload
      expect(profile.source_text).to be_present
      expect(profile.source_mode).to eq("upload")
    end

    it "extracts text from TXT and updates profile" do
      profile = create(:profile)
      profile.source_document.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/sample_resume.txt")),
        filename: "resume.txt",
        content_type: "text/plain"
      )

      result = described_class.new(profile).call

      expect(result).to include("Pankaj Kumar")
      profile.reload
      expect(profile.source_text).to include("Pankaj Kumar")
      expect(profile.source_mode).to eq("upload")
    end

    it "returns nil for image files (future LLM processing)" do
      profile = create(:profile)
      profile.source_document.attach(
        io: StringIO.new("fake image data"),
        filename: "resume.jpg",
        content_type: "image/jpeg"
      )

      result = described_class.new(profile).call
      expect(result).to be_nil
    end

    it "returns nil when no document attached" do
      profile = create(:profile)
      result = described_class.new(profile).call
      expect(result).to be_nil
    end
  end
end
