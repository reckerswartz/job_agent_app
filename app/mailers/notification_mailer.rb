class NotificationMailer < ApplicationMailer
  def scan_completed(user, scan_run)
    @user = user
    @scan_run = scan_run
    @source = scan_run.job_source

    mail(to: user.email, subject: "Scan complete: #{@source.name} — #{scan_run.new_listings} new listings")
  end

  def new_matches(user, listings)
    @user = user
    @listings = listings

    mail(to: user.email, subject: "#{listings.size} new high-match jobs found")
  end

  def application_status(user, job_application)
    @user = user
    @application = job_application
    @listing = job_application.job_listing

    status_text = job_application.status.humanize
    mail(to: user.email, subject: "Application #{status_text}: #{@listing.title} at #{@listing.company}")
  end

  def intervention_needed(user, intervention)
    @user = user
    @intervention = intervention

    mail(to: user.email, subject: "Action needed: #{intervention.type_label}")
  end
end
