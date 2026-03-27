require "rails_helper"

RSpec.describe ResumeParseJob, type: :job do
  describe "#perform" do
    it "calls the orchestrator with the profile" do
      profile = create(:profile)
      orchestrator = instance_double(ResumeParser::Orchestrator, call: "extracted text")
      allow(ResumeParser::Orchestrator).to receive(:new).with(profile).and_return(orchestrator)

      described_class.perform_now(profile.id)

      expect(ResumeParser::Orchestrator).to have_received(:new).with(profile)
      expect(orchestrator).to have_received(:call)
    end

    it "is enqueued on the parsing queue" do
      expect {
        described_class.perform_later(1)
      }.to have_enqueued_job.on_queue("parsing")
    end
  end
end
