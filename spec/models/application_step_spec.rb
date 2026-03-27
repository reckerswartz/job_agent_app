require "rails_helper"

RSpec.describe ApplicationStep, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:job_application) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:action) }
    it { is_expected.to validate_inclusion_of(:action).in_array(ApplicationStep::ACTIONS) }
    it { is_expected.to validate_inclusion_of(:status).in_array(ApplicationStep::STATUSES) }
  end

  describe "#mark_completed!" do
    it "sets status and finished_at" do
      step = create(:application_step, started_at: 1.second.ago)
      step.mark_completed!({ result: "ok" })
      expect(step.status).to eq("completed")
      expect(step.finished_at).to be_present
      expect(step.output_data["result"]).to eq("ok")
    end
  end

  describe "#mark_failed!" do
    it "records error message" do
      step = create(:application_step, started_at: 1.second.ago)
      step.mark_failed!("Element not found")
      expect(step.status).to eq("failed")
      expect(step.error_message).to eq("Element not found")
    end
  end

  describe "#duration_display" do
    it "returns formatted duration" do
      step = build(:application_step, started_at: 3.seconds.ago, finished_at: Time.current)
      expect(step.duration_display).to match(/\d+\.\ds/)
    end

    it "returns dash when incomplete" do
      step = build(:application_step, started_at: nil, finished_at: nil)
      expect(step.duration_display).to eq("—")
    end
  end
end
