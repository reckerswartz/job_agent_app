class DashboardActivityService
  LIMIT = 10

  def initialize(user)
    @user = user
  end

  def call
    events = []
    events.concat(scan_events)
    events.concat(listing_events)
    events.concat(application_events)
    events.concat(intervention_events)
    events.sort_by { |e| e[:time] }.reverse.first(LIMIT)
  end

  private

  attr_reader :user

  def scan_events
    runs = JobScanRun.joins(:job_source)
                     .where(job_sources: { user_id: user.id })
                     .where(status: "completed")
                     .order(finished_at: :desc)
                     .limit(5)
                     .includes(:job_source)

    runs.map do |run|
      {
        icon: "search",
        text: "Scanned <strong>#{run.job_source.name}</strong> — found #{run.listings_found} listings (#{run.new_listings} new)",
        time: run.finished_at || run.created_at,
        type: "scan"
      }
    end
  end

  def listing_events
    listings = JobListing.for_user(user)
                         .high_match
                         .where("job_listings.created_at > ?", 7.days.ago)
                         .order(created_at: :desc)
                         .limit(5)
                         .includes(:job_source)

    listings.map do |listing|
      {
        icon: "match",
        text: "New match: <strong>#{listing.title}</strong> at #{listing.company}",
        time: listing.created_at,
        type: "match"
      }
    end
  end

  def application_events
    apps = JobApplication.for_user(user)
                         .where(status: "submitted")
                         .order(applied_at: :desc)
                         .limit(5)
                         .includes(job_listing: :job_source)

    apps.map do |app|
      {
        icon: "applied",
        text: "Applied to <strong>#{app.job_listing.title}</strong> at #{app.job_listing.company}",
        time: app.applied_at || app.created_at,
        type: "applied"
      }
    end
  end

  def intervention_events
    interventions = user.interventions.pending.order(created_at: :desc).limit(3)

    interventions.map do |intervention|
      {
        icon: "alert",
        text: "Needs attention: <strong>#{intervention.type_label}</strong> — #{intervention.parent_description}",
        time: intervention.created_at,
        type: "alert"
      }
    end
  end
end
