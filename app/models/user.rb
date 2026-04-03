class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  has_many :profiles, dependent: :destroy
  has_many :job_sources, dependent: :destroy
  has_many :job_search_criteria, class_name: "JobSearchCriteria", dependent: :destroy
  has_many :interventions, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :webhook_endpoints, dependent: :destroy

  enum :role, { user: 0, admin: 1 }, validate: true

  before_validation :assign_initial_role, on: :create

  def notify?(key)
    notification_settings.fetch(key.to_s, true)
  end

  def auto_apply_enabled?
    notification_settings.fetch("auto_apply_enabled", false) == true
  end

  def auto_apply_threshold
    notification_settings.fetch("auto_apply_threshold", 80).to_i
  end

  def display_name
    email.split("@").first.humanize
  end

  def initials
    display_name.split.map(&:first).join.upcase.first(2)
  end

  def generate_api_token!
    update!(api_token: SecureRandom.hex(32))
    api_token
  end

  def masked_api_token
    return nil if api_token.blank?
    "#{api_token.first(8)}#{"*" * 48}#{api_token.last(8)}"
  end

  private

  def assign_initial_role
    self.role = User.where.not(id: id).none? ? :admin : :user if role.blank?
  end
end
