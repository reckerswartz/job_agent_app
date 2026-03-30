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

  private

  attr_reader :user
end
