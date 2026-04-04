class AnalyticsService
  PERIODS = {
    "7d" => 7.days,
    "30d" => 30.days,
    "90d" => 90.days,
    "all" => nil
  }.freeze

  def initialize(user, period: "all")
    @user = user
    @since = PERIODS[period] ? PERIODS[period].ago : nil
  end

  def listings_over_time
    scoped_listings.group_by_week(:created_at, last: 12).count
  end

  def match_score_distribution
    listings = scoped_listings.where.not(match_score: nil)
    {
      "Low (0-39)" => listings.where("match_score < 40").count,
      "Medium (40-69)" => listings.where("match_score >= 40 AND match_score < 70").count,
      "High (70-100)" => listings.where("match_score >= 70").count
    }
  end

  def applications_by_status
    scoped_applications.group(:status).count
  end

  def source_performance
    scoped_listings
      .joins(:job_source)
      .group("job_sources.platform")
      .count
      .transform_keys(&:capitalize)
  end

  def scan_activity
    scoped_scans.group_by_week(:created_at, last: 12).count
  end

  def top_companies
    scoped_listings
      .where.not(company: [ nil, "" ])
      .group(:company)
      .order("count_all DESC")
      .limit(10)
      .count
  end

  def salary_distribution
    listings = scoped_listings.where.not(salary_min: nil)
    buckets = {}
    [ [ 0, 50_000 ], [ 50_000, 100_000 ], [ 100_000, 150_000 ], [ 150_000, 200_000 ], [ 200_000, nil ] ].each do |min, max|
      label = max ? "#{min / 1000}K-#{max / 1000}K" : "#{min / 1000}K+"
      buckets[label] = max ? listings.where("salary_min >= ? AND salary_min < ?", min, max).count : listings.where("salary_min >= ?", min).count
    end
    buckets
  end

  def pipeline_distribution
    scoped_applications.group(:pipeline_stage).count
  end

  def scan_success_rate
    runs = scoped_scans
    total = runs.count
    { completed: runs.where(status: "completed").count, failed: runs.where(status: "failed").count, total: total,
      rate: total > 0 ? (runs.where(status: "completed").count * 100.0 / total).round : 0 }
  end

  def salary_by_source
    scoped_listings
      .where.not(salary_min: nil)
      .joins(:job_source)
      .group("job_sources.platform")
      .average(:salary_min)
      .transform_keys(&:capitalize)
      .transform_values { |v| v.to_i }
  end

  private

  attr_reader :user, :since

  def scoped_listings
    scope = JobListing.for_user(user)
    scope = scope.where("job_listings.created_at >= ?", since) if since
    scope
  end

  def scoped_applications
    scope = JobApplication.for_user(user)
    scope = scope.where("job_applications.created_at >= ?", since) if since
    scope
  end

  def scoped_scans
    scope = JobScanRun.joins(:job_source).where(job_sources: { user_id: user.id })
    scope = scope.where("job_scan_runs.created_at >= ?", since) if since
    scope
  end
end
