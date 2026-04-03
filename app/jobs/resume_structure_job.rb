class ResumeStructureJob < ApplicationJob
  queue_as :parsing

  def perform(profile_id)
    profile = Profile.find(profile_id)
    profile.update_column(:processing_status, "structuring")

    ResumeParser::TextStructurer.new(profile).call

    profile.update_column(:processing_status, "complete")
  rescue => e
    profile&.update_column(:processing_status, "failed")
    Rails.logger.error("[ResumeStructureJob] Failed for profile #{profile_id}: #{e.message}")
  end
end
