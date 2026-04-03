class WebhookDeliveryJob < ApplicationJob
  queue_as :default

  def perform(webhook_endpoint_id, event, payload)
    endpoint = WebhookEndpoint.find(webhook_endpoint_id)
    return unless endpoint.active?

    body = { event: event, payload: payload, timestamp: Time.current.iso8601 }.to_json
    signature = OpenSSL::HMAC.hexdigest("SHA256", endpoint.secret.to_s, body)

    uri = URI(endpoint.url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.read_timeout = 15
    http.open_timeout = 10

    request = Net::HTTP::Post.new(uri.path.presence || "/")
    request["Content-Type"] = "application/json"
    request["X-Webhook-Signature"] = "sha256=#{signature}"
    request["X-Webhook-Event"] = event
    request["User-Agent"] = "JobAgent-Webhook/1.0"
    request.body = body

    response = http.request(request)
    Rails.logger.info("[WebhookDeliveryJob] Delivered #{event} to #{endpoint.url}: #{response.code}")
  rescue => e
    Rails.logger.error("[WebhookDeliveryJob] Failed for endpoint #{webhook_endpoint_id}: #{e.message}")
  end
end
