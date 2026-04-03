class AutoApplyJob < ApplicationJob
  queue_as :applying

  MAX_PER_USER = 5

  def perform
    User.find_each do |user|
      next unless user.auto_apply_enabled?

      profile = user.profiles.first
      next unless profile

      listings = JobListing.for_user(user)
                           .where(status: "new", easy_apply: true)
                           .where("match_score >= ?", user.auto_apply_threshold)
                           .where.not(id: JobApplication.select(:job_listing_id))
                           .order(match_score: :desc)
                           .limit(MAX_PER_USER)

      listings.each do |listing|
        app = JobApplication.create!(job_listing: listing, profile: profile, status: "queued")
        JobApplyJob.perform_later(app.id)

        NotificationCreator.create(
          user: user, category: "application",
          title: "Auto-applied: #{listing.title}",
          body: "#{listing.company} — match score #{listing.match_score}%",
          action_url: "/job_applications/#{app.id}"
        )

        Rails.logger.info("[AutoApplyJob] Auto-applied to #{listing.title} for #{user.email}")
      end
    end
  end
end
