class StaleListingCleanupJob < ApplicationJob
  queue_as :default

  STALE_DAYS = 30

  def perform
    cutoff = STALE_DAYS.days.ago

    count = JobListing.where(status: "new")
                      .where("posted_at < :cutoff OR (posted_at IS NULL AND created_at < :cutoff)", cutoff: cutoff)
                      .update_all(status: "expired")

    Rails.logger.info("[StaleListingCleanupJob] Marked #{count} listings as expired")
  end
end
