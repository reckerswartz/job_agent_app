class JobListing < ApplicationRecord
  STATUSES = %w[new reviewed saved applied rejected expired].freeze

  belongs_to :job_source
  has_one :user, through: :job_source
  has_one :job_application, dependent: :destroy
  has_many :cover_letters, dependent: :destroy

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :recent, -> { order(posted_at: :desc, created_at: :desc) }
  scope :high_match, -> { where("match_score >= ?", 70) }
  scope :recommended, -> { where("match_score >= ?", 50).order(match_score: :desc) }
  scope :not_duplicate, -> { where(duplicate_of_id: nil) }

  belongs_to :duplicate_of, class_name: "JobListing", optional: true
  has_many :duplicates, class_name: "JobListing", foreign_key: :duplicate_of_id

  def duplicate?
    duplicate_of_id.present?
  end
  scope :for_user, ->(user) { joins(:job_source).where(job_sources: { user_id: user.id }) }
  scope :search, ->(query) {
    return all if query.blank?
    where("job_listings.title ILIKE :q OR job_listings.company ILIKE :q OR job_listings.location ILIKE :q", q: "%#{sanitize_sql_like(query)}%")
  }

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
