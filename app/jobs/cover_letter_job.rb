class CoverLetterJob < ApplicationJob
  queue_as :default

  def perform(job_listing_id, profile_id)
    listing = JobListing.find(job_listing_id)
    profile = Profile.find(profile_id)

    content = CoverLetterGenerator.new(listing, profile).call
    if content.present?
      listing.cover_letters.create!(profile: profile, content: content, tone: "professional", status: "draft")
    end
  end
end
