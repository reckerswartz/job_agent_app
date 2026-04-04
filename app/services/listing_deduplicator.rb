class ListingDeduplicator
  def initialize(user)
    @user = user
  end

  def deduplicate
    count = 0
    listings = JobListing.for_user(@user).where(duplicate_of_id: nil).order(:created_at)

    grouped = listings.group_by { |l| normalize_key(l) }

    grouped.each do |_key, group|
      next if group.size < 2

      # Keep the oldest (first found) as the primary
      primary = group.first
      group[1..].each do |dup|
        next if dup.duplicate_of_id.present?
        dup.update_column(:duplicate_of_id, primary.id)
        count += 1
      end
    end

    Rails.logger.info("[ListingDeduplicator] Marked #{count} duplicates for user #{@user.id}")
    count
  end

  private

  def normalize_key(listing)
    title = listing.title.to_s.downcase.gsub(/[^a-z0-9\s]/, "").gsub(/\s+/, " ").strip
    company = listing.company.to_s.downcase.gsub(/[^a-z0-9\s]/, "").gsub(/\s+/, " ").strip
    "#{title}|#{company}"
  end
end
