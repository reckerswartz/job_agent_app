require "rails_helper"

RSpec.describe JobScanJob, type: :job do
  let(:user) { create(:user) }
  let(:source) { create(:job_source, user: user) }
  let(:criteria) { create(:job_search_criteria, user: user) }

  it "is enqueued on the scanning queue" do
    expect {
      described_class.perform_later(source.id)
    }.to have_enqueued_job.on_queue("scanning")
  end

  it "creates a scan run and marks it completed" do
    expect {
      described_class.perform_now(source.id, criteria.id)
    }.to change(JobScanRun, :count).by(1)

    run = JobScanRun.last
    expect(run.status).to eq("completed")
    expect(run.job_source).to eq(source)
  end

  it "updates job_source.last_scanned_at" do
    expect(source.last_scanned_at).to be_nil
    described_class.perform_now(source.id)
    expect(source.reload.last_scanned_at).to be_present
  end
end
