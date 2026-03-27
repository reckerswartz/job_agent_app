class JobSource < ApplicationRecord
  PLATFORMS = %w[linkedin naukri indeed glassdoor wellfound custom].freeze
  STATUSES = %w[active paused error needs_login].freeze

  PLATFORM_URLS = {
    "linkedin" => "https://www.linkedin.com/jobs/search/",
    "naukri" => "https://www.naukri.com/",
    "indeed" => "https://www.indeed.com/jobs",
    "glassdoor" => "https://www.glassdoor.com/Job/",
    "wellfound" => "https://wellfound.com/jobs"
  }.freeze

  PLATFORM_COLORS = {
    "linkedin" => "primary",
    "naukri" => "danger",
    "indeed" => "purple",
    "glassdoor" => "success",
    "wellfound" => "warning",
    "custom" => "secondary"
  }.freeze

  belongs_to :user
  has_many :job_listings, dependent: :destroy
  has_many :job_scan_runs, dependent: :destroy

  validates :name, presence: true
  validates :platform, presence: true, inclusion: { in: PLATFORMS }
  validates :status, inclusion: { in: STATUSES }
  validates :scan_interval_hours, numericality: { greater_than: 0 }

  before_validation :set_default_base_url

  scope :enabled, -> { where(enabled: true) }
  scope :by_platform, ->(platform) { where(platform: platform) }
  scope :needs_scan, -> {
    enabled.where(status: "active").where(
      "last_scanned_at IS NULL OR last_scanned_at < NOW() - (scan_interval_hours || ' hours')::interval"
    )
  }

  def due_for_scan?
    return true if last_scanned_at.nil?

    last_scanned_at < scan_interval_hours.hours.ago
  end

  def platform_color
    PLATFORM_COLORS[platform] || "secondary"
  end

  def platform_url
    PLATFORM_URLS[platform]
  end

  private

  def set_default_base_url
    self.base_url = PLATFORM_URLS[platform] if base_url.blank? && PLATFORM_URLS.key?(platform)
  end
end
