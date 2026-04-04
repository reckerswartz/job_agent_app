class NotificationMailerPreview < ActionMailer::Preview
  def scan_completed
    user = User.first
    scan_run = JobScanRun.last || JobScanRun.new(
      job_source: JobSource.first || JobSource.new(name: "Preview LinkedIn", platform: "linkedin"),
      status: "completed", listings_found: 15, new_listings: 3,
      started_at: 2.minutes.ago, finished_at: Time.current
    )
    NotificationMailer.scan_completed(user, scan_run)
  end

  def new_matches
    user = User.first
    listings = JobListing.high_match.limit(5)
    listings = [ JobListing.new(title: "Senior Rails Dev", company: "Acme", match_score: 85) ] if listings.empty?
    NotificationMailer.new_matches(user, listings)
  end

  def application_status
    user = User.first
    app = JobApplication.last || JobApplication.new(
      status: "submitted", applied_at: Time.current,
      job_listing: JobListing.first || JobListing.new(title: "Ruby Engineer", company: "TechCo")
    )
    NotificationMailer.application_status(user, app)
  end

  def intervention_needed
    user = User.first
    intervention = Intervention.last || Intervention.new(
      intervention_type: "login_required",
      context: { "page_url" => "https://linkedin.com/login" }
    )
    NotificationMailer.intervention_needed(user, intervention)
  end
end
