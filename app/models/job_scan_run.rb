class JobScanRun < ApplicationRecord
  STATUSES = %w[queued running completed failed].freeze

  belongs_to :job_source
  belongs_to :job_search_criteria, class_name: "JobSearchCriteria", optional: true
  has_many_attached :screenshots

  validates :status, inclusion: { in: STATUSES }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) if status.present? }

  def mark_running!
    update!(status: "running", started_at: Time.current)
  end

  def mark_completed!(found:, new_count:)
    now = Time.current
    update!(
      status: "completed",
      finished_at: now,
      duration_ms: started_at ? ((now - started_at) * 1000).to_i : nil,
      listings_found: found,
      new_listings: new_count
    )
  end

  def mark_failed!(error)
    now = Time.current
    update!(
      status: "failed",
      finished_at: now,
      duration_ms: started_at ? ((now - started_at) * 1000).to_i : nil,
      error_details: { message: error.message, class: error.class.name, backtrace: error.backtrace&.first(5) }
    )
  end

  def duration_display
    return "—" if duration_ms.nil?

    seconds = duration_ms / 1000.0
    if seconds < 60
      "#{seconds.round(1)}s"
    else
      "#{(seconds / 60).floor}m #{(seconds % 60).round}s"
    end
  end

  def running?
    status == "running"
  end

  def completed?
    status == "completed"
  end

  def failed?
    status == "failed"
  end
end
