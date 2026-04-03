class ActivityLogger
  def self.log(user:, action:, category: nil, description: nil, trackable: nil, metadata: {}, ip: nil)
    user.activity_logs.create!(
      action: action,
      category: category,
      description: description,
      trackable: trackable,
      metadata: metadata,
      ip_address: ip
    )
  rescue => e
    Rails.logger.error("[ActivityLogger] Failed to log #{action}: #{e.message}")
    nil
  end
end
