class LlmVerification < ApplicationRecord
  STATUSES = %w[pending ok failed timeout].freeze

  belongs_to :llm_model

  validates :status, inclusion: { in: STATUSES }

  scope :recent, -> { order(created_at: :desc) }
  scope :for_model, ->(model) { where(llm_model: model) }
end
