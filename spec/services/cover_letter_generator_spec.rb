require "rails_helper"

RSpec.describe CoverLetterGenerator do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user: user, headline: "Senior Rails Dev", summary: "8+ years experience") }
  let(:job_source) { create(:job_source, user: user) }
  let(:listing) { create(:job_listing, job_source: job_source, title: "Staff Engineer", company: "Acme", description: "Build scalable systems") }

  subject(:generator) { described_class.new(listing, profile) }

  describe "#call" do
    let(:mock_client) { instance_double("Llm::Client") }

    before do
      allow(Llm::Client).to receive(:for_feature).with("cover_letter").and_return(mock_client)
    end

    it "generates a cover letter via LLM" do
      allow(mock_client).to receive(:chat).and_return({ content: "Dear Hiring Manager..." })
      result = generator.call
      expect(result).to eq("Dear Hiring Manager...")
    end

    it "returns nil when no LLM client available" do
      allow(Llm::Client).to receive(:for_feature).with("cover_letter").and_return(nil)
      expect(generator.call).to be_nil
    end

    it "returns nil and logs on LLM error" do
      allow(mock_client).to receive(:chat).and_raise(StandardError, "API timeout")
      expect(generator.call).to be_nil
    end

    it "includes listing and profile details in prompt" do
      allow(mock_client).to receive(:chat) do |messages, **_opts|
        prompt = messages.last[:content]
        expect(prompt).to include("Staff Engineer")
        expect(prompt).to include("Acme")
        expect(prompt).to include("Senior Rails Dev")
        { content: "Cover letter text" }
      end
      generator.call
    end
  end
end
