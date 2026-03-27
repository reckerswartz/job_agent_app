require "rails_helper"

RSpec.describe ResumeStructureJob, type: :job do
  it "is enqueued on the parsing queue" do
    expect {
      described_class.perform_later(1)
    }.to have_enqueued_job.on_queue("parsing")
  end
end
