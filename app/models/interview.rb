class Interview < ApplicationRecord
  STAGES = %w[phone_screen technical behavioral onsite final offer].freeze
  STATUSES = %w[scheduled completed cancelled no_show].freeze
  FORMATS = %w[video phone in_person].freeze

  belongs_to :job_application

  validates :stage, presence: true, inclusion: { in: STAGES }
  validates :status, inclusion: { in: STATUSES }
  validates :format, inclusion: { in: FORMATS }, allow_nil: true
  validates :rating, numericality: { in: 1..5 }, allow_nil: true

  scope :upcoming, -> { where(status: "scheduled").where("scheduled_at >= ?", Time.current).order(:scheduled_at) }
  scope :recent, -> { order(scheduled_at: :desc) }
  scope :for_user, ->(user) {
    joins(job_application: { job_listing: :job_source }).where(job_sources: { user_id: user.id })
  }

  def completed?
    status == "completed"
  end

  def stage_label
    stage.to_s.humanize.titleize
  end

  def parsed_prep_questions
    return [] if prep_questions.blank?
    JSON.parse(prep_questions)
  rescue JSON::ParserError
    prep_questions.split("\n").reject(&:blank?)
  end
end
