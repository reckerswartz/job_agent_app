class ProfileEntry < ApplicationRecord
  belongs_to :profile_section

  before_validation :assign_position, on: :create
  before_validation :normalize_content

  validates :content, presence: true

  def highlights
    Array(content["highlights"])
  end

  private

  def assign_position
    return if profile_section.blank? || position.to_i.positive?

    max_position = profile_section.profile_entries.where.not(id: id).maximum(:position)
    self.position = max_position.nil? ? 0 : max_position + 1
  end

  def normalize_content
    self.content = (content || {}).deep_stringify_keys
    self.content["highlights"] = Array(content["highlights"]).reject(&:blank?) if content.key?("highlights")
  end
end
