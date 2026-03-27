class CreateJobApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :job_applications do |t|
      t.references :job_listing, null: false, foreign_key: true, index: false
      t.references :profile, null: false, foreign_key: true
      t.string :status, default: "queued", null: false
      t.datetime :applied_at
      t.jsonb :error_details, default: {}, null: false
      t.jsonb :form_data_used, default: {}, null: false
      t.text :notes
      t.jsonb :metadata, default: {}, null: false

      t.timestamps
    end

    add_index :job_applications, :job_listing_id, unique: true
    add_index :job_applications, :status
  end
end
