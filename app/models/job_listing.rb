class JobListing < ApplicationRecord
  STATUSES = %w[new reviewed saved applied rejected expired].freeze

  belongs_to :job_source
  has_one :user, through: :job_source
  has_one :job_application, dependent: :destroy

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :recent, -> { order(posted_at: :desc, created_at: :desc) }
  scope :high_match, -> { where("match_score >= ?", 70) }
  scope :for_user, ->(user) { joins(:job_source).where(job_sources: { user_id: user.id }) }

  def match_level
    return nil if match_score.nil?

    case match_score
    when 70..100 then "high"
    when 40..69  then "medium"
    else "low"
    end
  end

  def match_badge_class
    case match_level
    when "high"   then "match-score--high"
    when "medium" then "match-score--medium"
    when "low"    then "match-score--low"
    else ""
    end
  end
end
