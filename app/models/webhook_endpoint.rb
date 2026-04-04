class WebhookEndpoint < ApplicationRecord
  EVENTS = %w[scan.completed listing.new application.status_changed].freeze

  belongs_to :user

  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }
  validates :events, presence: true

  scope :active, -> { where(active: true) }
  scope :for_event, ->(event) { active.where("events @> ?", [ event ].to_json) }

  before_create :generate_secret

  private

  def generate_secret
    self.secret ||= SecureRandom.hex(20)
  end
end
