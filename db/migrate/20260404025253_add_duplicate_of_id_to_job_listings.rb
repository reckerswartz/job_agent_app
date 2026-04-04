class AddDuplicateOfIdToJobListings < ActiveRecord::Migration[8.1]
  def change
    add_column :job_listings, :duplicate_of_id, :bigint
    add_index :job_listings, :duplicate_of_id
  end
end
