class WebhookDispatcher
  def self.fire(user, event, payload)
    WebhookEndpoint.where(user: user).for_event(event).find_each do |endpoint|
      WebhookDeliveryJob.perform_later(endpoint.id, event, payload)
    end
  end
end
