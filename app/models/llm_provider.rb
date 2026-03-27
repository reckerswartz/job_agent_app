class LlmProvider < ApplicationRecord
  ADAPTERS = %w[openai anthropic].freeze

  has_many :llm_models, dependent: :destroy
  has_many :llm_interactions, dependent: :nullify

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :adapter, presence: true, inclusion: { in: ADAPTERS }
  validates :base_url, presence: true

  scope :active, -> { where(active: true) }

  def api_key
    AppSetting.get(api_key_setting) if api_key_setting.present?
  end

  def available?
    active? && api_key.present?
  end

  def default_text_model
    llm_models.active.where(supports_text: true).first
  end

  def default_vision_model
    llm_models.active.where(supports_vision: true).first
  end
end
