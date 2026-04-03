module BadgeHelper
  BADGE_MAP = {
    listing: { "new" => "info", "reviewed" => "secondary", "saved" => "primary", "applied" => "success", "rejected" => "danger", "expired" => "dark" },
    application: { "queued" => "secondary", "in_progress" => "warning", "submitted" => "success", "failed" => "danger", "needs_intervention" => "info" },
    scan: { "queued" => "secondary", "running" => "warning", "completed" => "success", "failed" => "danger" },
    step: { "pending" => "secondary", "completed" => "success", "failed" => "danger", "skipped" => "dark" },
    intervention: { "pending" => "warning", "resolved" => "success", "dismissed" => "secondary" },
    verification: { "ok" => "success", "failed" => "danger", "timeout" => "warning", "untested" => "secondary" },
    model_type: { "text" => "primary", "vision" => "warning", "multimodal" => "info" },
    role: { "admin" => "danger", "user" => "secondary" }
  }.freeze

  def status_badge(value, context = :default)
    color = badge_color(value, context)
    content_tag(:span, value.to_s.humanize, class: "badge bg-#{color}")
  end

  def badge_color(value, context = :default)
    BADGE_MAP.dig(context, value.to_s) || "secondary"
  end
end
