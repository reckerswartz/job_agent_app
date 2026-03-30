class Profile < ApplicationRecord
  SOURCE_MODES = %w[scratch paste upload].freeze
  STATUSES = %w[draft complete].freeze
  CONTACT_FIELDS = %w[first_name surname email phone city country linkedin website].freeze

  belongs_to :user

  has_one_attached :source_document
  has_many :profile_sections, -> { order(position: :asc, created_at: :asc) }, dependent: :destroy, inverse_of: :profile

  validates :title, presence: true
  validates :source_mode, inclusion: { in: SOURCE_MODES }
  validates :status, inclusion: { in: STATUSES }

  before_validation :normalize_json_attributes

  def contact_field(key)
    contact_details.fetch(key.to_s, "")
  end

  def display_name
    full = [ contact_field("first_name"), contact_field("surname") ].reject(&:blank?).join(" ")
    full.presence || user.display_name
  end

  def complete?
    status == "complete"
  end

  def completeness_percentage
    score = 0
    score += 20 if contact_details.values_at("first_name", "surname", "email").all?(&:present?)
    score += 15 if headline.present?
    score += 15 if summary.present?
    score += 20 if source_document.attached?
    score += 30 if profile_sections.joins(:profile_entries).exists?
    score
  end

  def mark_complete!
    update!(status: "complete")
  end

  private

  def normalize_json_attributes
    self.contact_details = (contact_details || {}).deep_stringify_keys
    self.personal_details = (personal_details || {}).deep_stringify_keys
    self.settings = (settings || {}).deep_stringify_keys

    CONTACT_FIELDS.each do |field|
      contact_details[field] = contact_details[field].to_s.strip
    end
  end
end
