require "rails_helper"

RSpec.describe CoverLetterJob, type: :job do
  it "is enqueued on the default queue" do
    expect {
      described_class.perform_later(1, 1)
    }.to have_enqueued_job.on_queue("default")
  end
end
