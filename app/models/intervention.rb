class Intervention < ApplicationRecord
  TYPES = %w[login_required captcha account_creation unknown_field verification].freeze
  STATUSES = %w[pending resolved dismissed].freeze

  belongs_to :interventionable, polymorphic: true
  belongs_to :user
  has_one_attached :screenshot

  validates :intervention_type, presence: true, inclusion: { in: TYPES }
  validates :status, inclusion: { in: STATUSES }

  scope :pending, -> { where(status: "pending") }
  scope :resolved, -> { where(status: "resolved") }
  scope :dismissed, -> { where(status: "dismissed") }
  scope :by_type, ->(type) { where(intervention_type: type) if type.present? }
  scope :for_user, ->(user) { where(user: user) }
  scope :recent, -> { order(created_at: :desc) }

  def resolve!(input = {})
    update!(status: "resolved", user_input: input, resolved_at: Time.current)
  end

  def dismiss!
    update!(status: "dismissed", resolved_at: Time.current)
  end

  def pending?
    status == "pending"
  end

  def resolved?
    status == "resolved"
  end

  def type_label
    intervention_type.humanize
  end

  def type_icon
    case intervention_type
    when "login_required"    then "&#x1F512;"
    when "captcha"           then "&#x1F916;"
    when "account_creation"  then "&#x1F464;"
    when "unknown_field"     then "&#x2753;"
    when "verification"      then "&#x2705;"
    else "&#x26A0;"
    end
  end

  def type_color
    case intervention_type
    when "login_required"    then "warning"
    when "captcha"           then "info"
    when "account_creation"  then "primary"
    when "unknown_field"     then "secondary"
    when "verification"      then "success"
    else "danger"
    end
  end

  def parent_description
    case interventionable
    when JobApplication
      "Application: #{interventionable.job_listing.title} at #{interventionable.job_listing.company}"
    when JobScanRun
      "Scan Run ##{interventionable.id} for #{interventionable.job_source.name}"
    when JobSource
      "Source: #{interventionable.name} (#{interventionable.platform.capitalize})"
    else
      "#{interventionable_type} ##{interventionable_id}"
    end
  end
end
