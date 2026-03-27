class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :profiles, dependent: :destroy

  enum :role, { user: 0, admin: 1 }, validate: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }

  before_validation :assign_initial_role, on: :create

  def display_name
    email_address.split("@").first.humanize
  end

  def initials
    display_name.split.map(&:first).join.upcase.first(2)
  end

  private

  def assign_initial_role
    self.role = User.where.not(id: id).none? ? :admin : :user if role.blank?
  end
end
