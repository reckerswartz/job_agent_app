require "rails_helper"

RSpec.describe JobRescoreJob, type: :job do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user: user) }
  let(:job_source) { create(:job_source, user: user) }

  describe "#perform" do
    it "re-scores listings using JobMatcherService" do
      profile # ensure profile exists
      listing = create(:job_listing, job_source: job_source, match_score: nil)
      allow_any_instance_of(JobMatcherService).to receive(:call).and_return(85)

      described_class.new.perform(user.id)
      expect(listing.reload.match_score).to eq(85)
    end

    it "skips users without a profile" do
      user_no_profile = create(:user)
      expect { described_class.new.perform(user_no_profile.id) }.not_to raise_error
    end

    it "only updates listings with changed scores" do
      listing = create(:job_listing, job_source: job_source, match_score: 70)
      allow_any_instance_of(JobMatcherService).to receive(:call).and_return(70)

      expect { described_class.new.perform(user.id) }.not_to change { listing.reload.updated_at }
    end
  end
end
