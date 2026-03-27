require "rails_helper"

RSpec.describe DailyMatchDigestJob, type: :job do
  it "is enqueued on the default queue" do
    expect {
      described_class.perform_later
    }.to have_enqueued_job.on_queue("default")
  end

  it "sends digest email to users with new high matches" do
    user = create(:user)
    source = create(:job_source, user: user)
    create(:job_listing, :high_match, job_source: source, created_at: 1.hour.ago)

    expect {
      described_class.perform_now
    }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
  end

  it "skips users with no new matches" do
    create(:user)

    expect {
      described_class.perform_now
    }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
  end
end
