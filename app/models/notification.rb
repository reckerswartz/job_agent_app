class Notification < ApplicationRecord
  CATEGORIES = %w[scan application intervention system].freeze

  belongs_to :user

  validates :title, presence: true
  validates :category, inclusion: { in: CATEGORIES }, allow_nil: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  after_create_commit :broadcast_to_user

  def read?
    read_at.present?
  end

  def mark_read!
    update!(read_at: Time.current) unless read?
  end

  private

  def broadcast_to_user
    NotificationsChannel.broadcast_to(user, {
      id: id, title: title, body: body, category: category,
      action_url: action_url, created_at: created_at.iso8601
    })
  rescue => e
    Rails.logger.debug("[Notification] Broadcast skipped: #{e.message}")
  end
end
