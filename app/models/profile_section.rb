class ProfileSection < ApplicationRecord
  SECTION_TYPES = %w[work_experience education skills certifications projects languages].freeze
  SECTION_TITLES = {
    "work_experience" => "Work Experience",
    "education" => "Education",
    "skills" => "Skills",
    "certifications" => "Certifications",
    "projects" => "Projects",
    "languages" => "Languages"
  }.freeze

  belongs_to :profile
  has_many :profile_entries, -> { order(position: :asc, created_at: :asc) }, dependent: :destroy, inverse_of: :profile_section

  validates :section_type, presence: true, inclusion: { in: SECTION_TYPES }
  validates :title, presence: true

  before_validation :assign_position, on: :create
  before_validation :default_title
  before_validation :normalize_settings

  def ordered_entries
    profile_entries
  end

  private

  def assign_position
    return if profile.blank? || position.to_i.positive?

    max_position = profile.profile_sections.where.not(id: id).maximum(:position)
    self.position = max_position.nil? ? 0 : max_position + 1
  end

  def default_title
    self.title = SECTION_TITLES[section_type] if title.blank? && section_type.present?
  end

  def normalize_settings
    self.settings = (settings || {}).deep_stringify_keys
  end
end
