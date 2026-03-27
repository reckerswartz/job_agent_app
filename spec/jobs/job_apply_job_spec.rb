require "rails_helper"

RSpec.describe JobApplyJob, type: :job do
  let(:user) { create(:user) }
  let(:source) { create(:job_source, user: user) }
  let(:listing) { create(:job_listing, job_source: source, url: "https://example.com/apply") }
  let(:profile) { create(:profile, user: user) }
  let!(:application) { create(:job_application, job_listing: listing, profile: profile) }

  it "is enqueued on the applying queue" do
    expect {
      described_class.perform_later(application.id)
    }.to have_enqueued_job.on_queue("applying")
  end

  it "creates application steps and marks as submitted" do
    described_class.perform_now(application.id)

    application.reload
    expect(application.status).to eq("submitted")
    expect(application.applied_at).to be_present
    expect(application.application_steps.count).to be >= 4
    expect(application.form_data_used).to be_present
  end

  it "updates the listing status to applied" do
    described_class.perform_now(application.id)
    expect(listing.reload.status).to eq("applied")
  end
end
