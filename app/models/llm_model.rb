class LlmModel < ApplicationRecord
  belongs_to :llm_provider
  has_many :llm_interactions, dependent: :nullify

  validates :name, presence: true
  validates :identifier, presence: true, uniqueness: { scope: :llm_provider_id }

  scope :active, -> { where(active: true) }
  scope :text_capable, -> { where(supports_text: true) }
  scope :vision_capable, -> { where(supports_vision: true) }

  def available?
    active? && llm_provider.available?
  end
end
