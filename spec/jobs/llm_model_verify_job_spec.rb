require "rails_helper"

RSpec.describe LlmModelVerifyJob, type: :job do
  let(:provider) { create(:llm_provider) }
  let(:model) { create(:llm_model, llm_provider: provider, active: true) }

  describe "#perform" do
    let(:mock_adapter) { instance_double("Llm::NvidiaAdapter") }

    before do
      allow(Llm::NvidiaAdapter).to receive(:new).and_return(mock_adapter)
      allow_any_instance_of(LlmProvider).to receive(:available?).and_return(true)
    end

    it "creates a verification record and marks model as ok on success" do
      allow(mock_adapter).to receive(:chat).and_return({ content: "OK" })
      described_class.new.perform(model.id)

      model.reload
      expect(model.verification_status).to eq("ok")
      expect(model.last_verified_at).not_to be_nil
      expect(model.llm_verifications.last.status).to eq("ok")
    end

    it "marks model as failed on adapter error" do
      allow(mock_adapter).to receive(:chat).and_raise(StandardError, "API error")
      described_class.new.perform(model.id)

      model.reload
      expect(model.verification_status).to eq("failed")
    end

    it "skips inactive models" do
      model.update!(active: false)
      expect(Llm::NvidiaAdapter).not_to receive(:new)
      described_class.new.perform(model.id)
    end
  end
end
