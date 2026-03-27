class ResumeStructureJob < ApplicationJob
  queue_as :parsing

  def perform(profile_id)
    profile = Profile.find(profile_id)
    ResumeParser::TextStructurer.new(profile).call
  end
end
