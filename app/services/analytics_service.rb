class AnalyticsService
  def initialize(user)
    @user = user
  end

  def listings_over_time
    JobListing.for_user(user).group_by_week(:created_at, last: 12).count
  end

  def match_score_distribution
    listings = JobListing.for_user(user).where.not(match_score: nil)
    {
      "Low (0-39)" => listings.where("match_score < 40").count,
      "Medium (40-69)" => listings.where("match_score >= 40 AND match_score < 70").count,
      "High (70-100)" => listings.where("match_score >= 70").count
    }
  end

  def applications_by_status
    JobApplication.for_user(user).group(:status).count
  end

  def source_performance
    JobListing.for_user(user)
              .joins(:job_source)
              .group("job_sources.platform")
              .count
              .transform_keys(&:capitalize)
  end

  def scan_activity
    JobScanRun.joins(:job_source)
              .where(job_sources: { user_id: user.id })
              .group_by_week(:created_at, last: 12)
              .count
  end

  def top_companies
    JobListing.for_user(user)
              .where.not(company: [ nil, "" ])
              .group(:company)
              .order("count_all DESC")
              .limit(10)
              .count
  end

  def salary_distribution
    listings = JobListing.for_user(user).where.not(salary_min: nil)
    buckets = {}
    [ [ 0, 50_000 ], [ 50_000, 100_000 ], [ 100_000, 150_000 ], [ 150_000, 200_000 ], [ 200_000, nil ] ].each do |min, max|
      label = max ? "#{min / 1000}K-#{max / 1000}K" : "#{min / 1000}K+"
      buckets[label] = max ? listings.where("salary_min >= ? AND salary_min < ?", min, max).count : listings.where("salary_min >= ?", min).count
    end
    buckets
  end

  def pipeline_distribution
    JobApplication.for_user(user).group(:pipeline_stage).count
  end

  def scan_success_rate
    runs = JobScanRun.joins(:job_source).where(job_sources: { user_id: user.id })
    total = runs.count
    { completed: runs.where(status: "completed").count, failed: runs.where(status: "failed").count, total: total,
      rate: total > 0 ? (runs.where(status: "completed").count * 100.0 / total).round : 0 }
  end

  def salary_by_source
    JobListing.for_user(user)
              .where.not(salary_min: nil)
              .joins(:job_source)
              .group("job_sources.platform")
              .average(:salary_min)
              .transform_keys(&:capitalize)
              .transform_values { |v| v.to_i }
  end

  private

  attr_reader :user
end
