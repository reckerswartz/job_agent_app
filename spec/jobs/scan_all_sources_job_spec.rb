require "rails_helper"

RSpec.describe ScanAllSourcesJob, type: :job do
  it "is enqueued on the scanning queue" do
    expect {
      described_class.perform_later
    }.to have_enqueued_job.on_queue("scanning")
  end

  it "enqueues JobScanJob for each source needing scan" do
    user = create(:user)
    source = create(:job_source, user: user, enabled: true, status: "active", last_scanned_at: nil)
    create(:job_source, user: user, enabled: false) # disabled, should not be scanned

    expect {
      described_class.perform_now
    }.to have_enqueued_job(JobScanJob).with(source.id, nil)
  end
end
