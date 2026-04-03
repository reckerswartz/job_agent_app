class ActivityLog < ApplicationRecord
  CATEGORIES = %w[scan listing application profile settings auth admin].freeze

  belongs_to :user
  belongs_to :trackable, polymorphic: true, optional: true

  validates :action, presence: true
  validates :category, inclusion: { in: CATEGORIES }, allow_nil: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_category, ->(cat) { where(category: cat) if cat.present? }
end
