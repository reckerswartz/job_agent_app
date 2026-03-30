class JobSearchCriteria < ApplicationRecord
  REMOTE_PREFERENCES = %w[onsite remote hybrid any].freeze
  EXPERIENCE_LEVELS = %w[entry mid senior lead executive].freeze
  JOB_TYPES = %w[full_time part_time contract internship].freeze

  belongs_to :user

  validates :name, presence: true
  validates :remote_preference, inclusion: { in: REMOTE_PREFERENCES }
  validates :job_type, inclusion: { in: JOB_TYPES }
  validates :experience_level, inclusion: { in: EXPERIENCE_LEVELS }, allow_blank: true
  validates :salary_min, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :salary_max, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :default_criteria, -> { where(is_default: true) }

  after_save :ensure_single_default, if: :is_default?

  def summary
    parts = []
    parts << keywords if keywords.present?
    parts << location if location.present?
    parts << remote_preference.humanize unless remote_preference == "any"
    parts << job_type.humanize unless job_type == "full_time"
    parts << experience_level.humanize if experience_level.present?
    if salary_min.present? || salary_max.present?
      range = [ salary_min, salary_max ].compact.map { |s| "$#{s.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}" }
      parts << range.join(" – ")
    end
    parts.join(" · ")
  end

  private

  def ensure_single_default
    user.job_search_criteria.where.not(id: id).update_all(is_default: false)
  end
end
