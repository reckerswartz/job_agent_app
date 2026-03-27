class DailyMatchDigestJob < ApplicationJob
  queue_as :default

  def perform
    User.find_each do |user|
      next unless user.notify?("email_new_matches")

      listings = JobListing.for_user(user)
                           .high_match
                           .where("job_listings.created_at > ?", 24.hours.ago)
                           .recent
                           .limit(20)

      next if listings.empty?

      NotificationMailer.new_matches(user, listings.to_a).deliver_later
    end
  end
end
