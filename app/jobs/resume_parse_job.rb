class ResumeParseJob < ApplicationJob
  queue_as :parsing

  def perform(profile_id)
    profile = Profile.find(profile_id)
    profile.update_column(:processing_status, "parsing")

    ResumeParser::Orchestrator.new(profile).call

    # Auto-chain AI structuring if text was extracted and LLM is available
    if profile.reload.source_text.present? && LlmProvider.active.any?(&:available?)
      ResumeStructureJob.perform_later(profile.id)
    else
      profile.update_column(:processing_status, "idle")
    end
  rescue => e
    profile&.update_column(:processing_status, "failed")
    Rails.logger.error("[ResumeParseJob] Failed for profile #{profile_id}: #{e.message}")
  end
end
