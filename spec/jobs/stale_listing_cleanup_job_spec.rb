require "rails_helper"

RSpec.describe StaleListingCleanupJob, type: :job do
  let(:user) { create(:user) }
  let(:source) { create(:job_source, user: user) }

  it "marks old new listings as expired" do
    old_listing = create(:job_listing, job_source: source, status: "new", posted_at: 31.days.ago)
    recent_listing = create(:job_listing, job_source: source, status: "new", posted_at: 1.day.ago)

    described_class.perform_now

    expect(old_listing.reload.status).to eq("expired")
    expect(recent_listing.reload.status).to eq("new")
  end

  it "does not touch non-new listings" do
    saved_listing = create(:job_listing, job_source: source, status: "saved", posted_at: 60.days.ago)

    described_class.perform_now

    expect(saved_listing.reload.status).to eq("saved")
  end

  it "uses created_at as fallback when posted_at is nil" do
    old_listing = create(:job_listing, job_source: source, status: "new", posted_at: nil)
    old_listing.update_column(:created_at, 31.days.ago)

    described_class.perform_now

    expect(old_listing.reload.status).to eq("expired")
  end
end
