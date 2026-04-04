require "rails_helper"

RSpec.describe AutoApplyJob, type: :job do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user: user) }
  let(:source) { create(:job_source, user: user) }

  before do
    user.update!(notification_settings: user.notification_settings.merge(
      "auto_apply_enabled" => true,
      "auto_apply_threshold" => 70
    ))
    profile
  end

  it "creates applications for high-match Easy Apply listings" do
    listing = create(:job_listing, job_source: source, status: "new", easy_apply: true, match_score: 85)

    expect { described_class.perform_now }.to change(JobApplication, :count).by(1)
    expect(listing.reload.job_application).to be_present
  end

  it "skips listings below threshold" do
    create(:job_listing, job_source: source, status: "new", easy_apply: true, match_score: 50)

    expect { described_class.perform_now }.not_to change(JobApplication, :count)
  end

  it "skips non-Easy Apply listings" do
    create(:job_listing, job_source: source, status: "new", easy_apply: false, match_score: 90)

    expect { described_class.perform_now }.not_to change(JobApplication, :count)
  end

  it "skips users with auto_apply disabled" do
    user.update!(notification_settings: user.notification_settings.merge("auto_apply_enabled" => false))
    create(:job_listing, job_source: source, status: "new", easy_apply: true, match_score: 90)

    expect { described_class.perform_now }.not_to change(JobApplication, :count)
  end
end
