module JobApplicationsHelper
  def application_status_color(status)
    case status.to_s
    when "queued"             then "secondary"
    when "in_progress"        then "warning"
    when "submitted"          then "success"
    when "failed"             then "danger"
    when "needs_intervention" then "info"
    else "secondary"
    end
  end

  def step_status_color(status)
    case status.to_s
    when "pending"   then "secondary"
    when "completed" then "success"
    when "failed"    then "danger"
    when "skipped"   then "dark"
    else "secondary"
    end
  end
end
