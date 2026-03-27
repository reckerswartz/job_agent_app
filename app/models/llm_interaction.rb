class LlmInteraction < ApplicationRecord
  FEATURES = %w[resume_parse resume_structure match_score cover_letter].freeze
  STATUSES = %w[pending completed failed].freeze

  belongs_to :user
  belongs_to :profile, optional: true
  belongs_to :llm_provider, optional: true
  belongs_to :llm_model, optional: true

  validates :feature_name, presence: true, inclusion: { in: FEATURES }
  validates :status, inclusion: { in: STATUSES }

  scope :by_feature, ->(feature) { where(feature_name: feature) if feature.present? }
  scope :recent, -> { order(created_at: :desc) }
  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }

  def mark_completed!(response_text, usage = {}, ms = nil)
    update!(
      status: "completed",
      response: response_text,
      token_usage: usage,
      latency_ms: ms
    )
  end

  def mark_failed!(error_message)
    update!(status: "failed", response: error_message)
  end
end
