class SavedSearch < ApplicationRecord
  belongs_to :user

  validates :name, presence: true

  scope :recent, -> { order(created_at: :desc) }

  def filter_url
    params = (filters || {}).compact_blank
    "/job_listings?#{params.to_query}"
  end
end
