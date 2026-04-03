class AddMatchBreakdownToJobListings < ActiveRecord::Migration[8.1]
  def change
    add_column :job_listings, :match_breakdown, :jsonb, default: {}
  end
end
