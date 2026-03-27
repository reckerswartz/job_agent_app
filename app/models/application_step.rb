class ApplicationStep < ApplicationRecord
  ACTIONS = %w[navigate fill_form upload_resume click_submit screenshot login verify error].freeze
  STATUSES = %w[pending completed failed skipped].freeze

  belongs_to :job_application
  has_one_attached :screenshot

  validates :action, presence: true, inclusion: { in: ACTIONS }
  validates :status, inclusion: { in: STATUSES }

  def mark_completed!(output = {})
    update!(status: "completed", finished_at: Time.current, output_data: output)
  end

  def mark_failed!(message)
    update!(status: "failed", finished_at: Time.current, error_message: message)
  end

  def completed?
    status == "completed"
  end

  def failed?
    status == "failed"
  end

  def duration_display
    return "—" unless started_at && finished_at

    ms = ((finished_at - started_at) * 1000).to_i
    "#{(ms / 1000.0).round(1)}s"
  end
end
