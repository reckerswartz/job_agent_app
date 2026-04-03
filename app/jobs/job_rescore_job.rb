class JobRescoreJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    profile = user.profiles.first
    return unless profile

    listings = JobListing.for_user(user)
    count = 0

    listings.find_each do |listing|
      listing.match_score = JobMatcherService.new(listing, profile).call
      listing.save! if listing.match_score_changed?
      count += 1
    end

    Rails.logger.info("[JobRescoreJob] Re-scored #{count} listings for user #{user.id}")
  end
end
