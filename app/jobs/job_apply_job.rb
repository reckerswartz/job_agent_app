class JobApplyJob < ApplicationJob
  queue_as :applying

  def perform(job_application_id)
    application = JobApplication.find(job_application_id)
    applier = applier_for(application)
    applier.apply
  rescue => e
    Rails.logger.error("[JobApplyJob] Failed for application #{job_application_id}: #{e.message}")
  end

  private

  def applier_for(application)
    listing = application.job_listing
    if listing.job_source.platform == "linkedin" && listing.easy_apply?
      JobApplier::LinkedinApplier.new(application)
    else
      JobApplier::Base.new(application)
    end
  end
end
