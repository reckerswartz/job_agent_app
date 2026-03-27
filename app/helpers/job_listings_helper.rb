module JobListingsHelper
  def status_badge_color(status)
    case status.to_s
    when "new"      then "info"
    when "reviewed" then "secondary"
    when "saved"    then "primary"
    when "applied"  then "success"
    when "rejected" then "danger"
    when "expired"  then "dark"
    else "secondary"
    end
  end

  def scan_status_color(status)
    case status.to_s
    when "queued"    then "secondary"
    when "running"   then "warning"
    when "completed" then "success"
    when "failed"    then "danger"
    else "secondary"
    end
  end
end
