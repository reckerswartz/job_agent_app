class JobListingNote < ApplicationRecord
  belongs_to :job_listing
  belongs_to :user

  validates :content, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
