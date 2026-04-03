class NotificationCreator
  def self.create(user:, title:, body: nil, category: nil, action_url: nil)
    user.notifications.create!(
      title: title,
      body: body,
      category: category,
      action_url: action_url
    )
  rescue => e
    Rails.logger.error("[NotificationCreator] Failed: #{e.message}")
    nil
  end
end
