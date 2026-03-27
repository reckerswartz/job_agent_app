class CreateJobListings < ActiveRecord::Migration[8.1]
  def change
    create_table :job_listings do |t|
      t.references :job_source, null: false, foreign_key: true
      t.string :external_id
      t.string :title, null: false
      t.string :company
      t.string :location
      t.string :salary_range
      t.text :description
      t.text :requirements
      t.string :url
      t.datetime :posted_at
      t.datetime :expires_at
      t.string :employment_type
      t.string :remote_type
      t.jsonb :raw_data, default: {}, null: false
      t.string :status, default: "new", null: false
      t.integer :match_score
      t.jsonb :metadata, default: {}, null: false

      t.timestamps
    end

    add_index :job_listings, [:job_source_id, :external_id], unique: true
    add_index :job_listings, [:job_source_id, :status]
    add_index :job_listings, :match_score
    add_index :job_listings, :status
  end
end
