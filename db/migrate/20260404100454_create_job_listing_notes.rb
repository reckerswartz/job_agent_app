class CreateJobListingNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :job_listing_notes do |t|
      t.references :job_listing, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
