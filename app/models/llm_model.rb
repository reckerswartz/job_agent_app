class LlmModel < ApplicationRecord
  MODEL_TYPES = %w[text vision multimodal].freeze
  ROLES = %w[primary_text primary_vision verification].freeze

  belongs_to :llm_provider
  has_many :llm_interactions, dependent: :nullify

  validates :name, presence: true
  validates :identifier, presence: true, uniqueness: { scope: :llm_provider_id }
  validates :model_type, inclusion: { in: MODEL_TYPES }
  validates :role, inclusion: { in: ROLES }, allow_nil: true

  scope :active, -> { where(active: true) }
  scope :text_capable, -> { where(supports_text: true) }
  scope :vision_capable, -> { where(supports_vision: true) }
  scope :by_role, ->(role) { where(role: role) }
  scope :by_type, ->(type) { where(model_type: type) }

  def available?
    active? && llm_provider.available?
  end

  def vision?
    model_type.in?(%w[vision multimodal])
  end

  def multimodal?
    model_type == "multimodal"
  end
end
