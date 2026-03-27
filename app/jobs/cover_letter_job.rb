class CoverLetterJob < ApplicationJob
  queue_as :default

  def perform(job_listing_id, profile_id)
    listing = JobListing.find(job_listing_id)
    profile = Profile.find(profile_id)

    cover_letter = CoverLetterGenerator.new(listing, profile).call
    if cover_letter.present?
      listing.update!(metadata: listing.metadata.merge("cover_letter" => cover_letter))
    end
  end
end
