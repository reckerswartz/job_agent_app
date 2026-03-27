class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  has_many :profiles, dependent: :destroy

  enum :role, { user: 0, admin: 1 }, validate: true

  before_validation :assign_initial_role, on: :create

  def display_name
    email.split("@").first.humanize
  end

  def initials
    display_name.split.map(&:first).join.upcase.first(2)
  end

  private

  def assign_initial_role
    self.role = User.where.not(id: id).none? ? :admin : :user if role.blank?
  end
end
