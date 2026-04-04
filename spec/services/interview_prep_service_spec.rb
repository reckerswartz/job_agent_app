require "rails_helper"

RSpec.describe InterviewPrepService do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user: user, headline: "Senior Rails Developer") }
  let(:job_source) { create(:job_source, user: user) }
  let(:listing) { create(:job_listing, job_source: job_source, title: "Staff Engineer", company: "GitHub", description: "Build dev tools") }
  let(:application) { create(:job_application, job_listing: listing, profile: profile) }
  let(:interview) { create(:interview, job_application: application, stage: "technical") }

  subject(:service) { described_class.new(interview) }

  describe "#generate_questions" do
    let(:mock_client) { instance_double("Llm::Client") }
    let(:questions) { ["Tell me about Rails", "Describe a scaling challenge", "How do you handle deadlines?"] }

    before do
      allow(Llm::Client).to receive(:for_feature).with("interview_prep").and_return(mock_client)
    end

    it "generates questions and saves them to the interview" do
      allow(mock_client).to receive(:chat).and_return({ content: questions.to_json })
      result = service.generate_questions
      expect(result).to eq(questions)
      expect(interview.reload.prep_questions).to eq(questions.to_json)
    end

    it "returns nil when no LLM client available" do
      allow(Llm::Client).to receive(:for_feature).with("interview_prep").and_return(nil)
      expect(service.generate_questions).to be_nil
    end

    it "returns nil on JSON parse error" do
      allow(mock_client).to receive(:chat).and_return({ content: "not valid json" })
      expect(service.generate_questions).to be_nil
    end

    it "returns nil on LLM error" do
      allow(mock_client).to receive(:chat).and_raise(StandardError, "timeout")
      expect(service.generate_questions).to be_nil
    end

    it "strips markdown code fences from response" do
      allow(mock_client).to receive(:chat).and_return({ content: "```json\n#{questions.to_json}\n```" })
      result = service.generate_questions
      expect(result).to eq(questions)
    end
  end
end
