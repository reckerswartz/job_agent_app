class AddApplicationFieldsToJobListings < ActiveRecord::Migration[8.1]
  def change
    add_column :job_listings, :easy_apply, :boolean, default: false
    add_column :job_listings, :resume_upload_supported, :boolean, default: false
    add_column :job_listings, :application_url, :string
    add_index :job_listings, :easy_apply
  end
end
