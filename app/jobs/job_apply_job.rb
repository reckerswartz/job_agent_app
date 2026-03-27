class JobApplyJob < ApplicationJob
  queue_as :applying

  def perform(job_application_id)
    application = JobApplication.find(job_application_id)
    JobApplier::Base.new(application).apply
  rescue => e
    Rails.logger.error("[JobApplyJob] Failed for application #{job_application_id}: #{e.message}")
  end
end
