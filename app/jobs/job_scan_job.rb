class JobScanJob < ApplicationJob
  queue_as :scanning

  def perform(job_source_id, job_search_criteria_id = nil)
    source = JobSource.find(job_source_id)
    criteria = job_search_criteria_id ? JobSearchCriteria.find(job_search_criteria_id) : nil

    scan_run = source.job_scan_runs.create!(
      job_search_criteria: criteria,
      status: "running",
      started_at: Time.current
    )

    begin
      scanner = scanner_for(source, criteria)
      raw_listings = scanner.scan

      found_count = raw_listings.size
      new_count = 0

      profile = source.user.profiles.first

      raw_listings.each do |listing_data|
        listing = source.job_listings.find_or_initialize_by(external_id: listing_data[:external_id])
        was_new = listing.new_record?

        listing.assign_attributes(
          title: listing_data[:title],
          company: listing_data[:company],
          location: listing_data[:location],
          salary_range: listing_data[:salary_range],
          description: listing_data[:description],
          requirements: listing_data[:requirements],
          url: listing_data[:url],
          posted_at: listing_data[:posted_at],
          employment_type: listing_data[:employment_type],
          remote_type: listing_data[:remote_type],
          raw_data: listing_data[:raw_data] || {}
        )

        if profile
          listing.match_score = JobMatcherService.new(listing, profile).call
        end

        listing.save!
        new_count += 1 if was_new
      end

      scan_run.mark_completed!(found: found_count, new_count: new_count)
      source.update!(last_scanned_at: Time.current)

      if new_count > 0 && source.user.notify?("email_scan_completed")
        NotificationMailer.scan_completed(source.user, scan_run).deliver_later
      end

    rescue => e
      Rails.logger.error("[JobScanJob] Failed for source #{source.id}: #{e.message}")
      scan_run.mark_failed!(e)
    end
  end

  private

  def scanner_for(source, criteria)
    case source.platform
    when "linkedin"  then JobScanner::LinkedinScanner.new(source, criteria)
    when "indeed"    then JobScanner::IndeedScanner.new(source, criteria)
    when "naukri"    then JobScanner::NaukriScanner.new(source, criteria)
    else JobScanner::GenericScanner.new(source, criteria)
    end
  end
end
