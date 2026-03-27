class JobApplication < ApplicationRecord
  STATUSES = %w[queued in_progress submitted failed needs_intervention].freeze

  belongs_to :job_listing
  belongs_to :profile
  has_many :application_steps, -> { order(step_number: :asc) }, dependent: :destroy

  validates :status, inclusion: { in: STATUSES }
  validates :job_listing_id, uniqueness: { message: "already has an application" }

  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) {
    joins(job_listing: :job_source).where(job_sources: { user_id: user.id })
  }

  def mark_in_progress!
    update!(status: "in_progress")
  end

  def mark_submitted!
    update!(status: "submitted", applied_at: Time.current)
  end

  def mark_failed!(error)
    update!(
      status: "failed",
      error_details: { message: error.message, class: error.class.name, backtrace: error.backtrace&.first(5) }
    )
  end

  def mark_needs_intervention!(reason)
    update!(
      status: "needs_intervention",
      error_details: { reason: reason }
    )
  end

  def submitted?
    status == "submitted"
  end

  def failed?
    status == "failed"
  end

  def can_retry?
    failed? || status == "needs_intervention"
  end

  def duration
    first_step = application_steps.minimum(:started_at)
    last_step = application_steps.maximum(:finished_at)
    return nil unless first_step && last_step

    ((last_step - first_step) * 1000).to_i
  end

  def duration_display
    ms = duration
    return "—" if ms.nil?

    seconds = ms / 1000.0
    if seconds < 60
      "#{seconds.round(1)}s"
    else
      "#{(seconds / 60).floor}m #{(seconds % 60).round}s"
    end
  end
end
