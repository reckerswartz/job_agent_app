class ResumeParseJob < ApplicationJob
  queue_as :parsing

  def perform(profile_id)
    profile = Profile.find(profile_id)
    ResumeParser::Orchestrator.new(profile).call
  end
end
