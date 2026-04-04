class ListingEnrichJob < ApplicationJob
  queue_as :default

  def perform(job_listing_id)
    listing = JobListing.find(job_listing_id)
    ListingEnricher.new(listing).enrich
  end
end
