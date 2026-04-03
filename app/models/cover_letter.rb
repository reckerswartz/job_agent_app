class CoverLetter < ApplicationRecord
  TONES = %w[professional casual technical].freeze
  STATUSES = %w[draft final].freeze

  belongs_to :job_listing
  belongs_to :profile

  validates :content, presence: true
  validates :tone, inclusion: { in: TONES }, allow_nil: true
  validates :status, inclusion: { in: STATUSES }, allow_nil: true

  scope :recent, -> { order(created_at: :desc) }
end
