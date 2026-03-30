class CreateJobScanRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :job_scan_runs do |t|
      t.references :job_source, null: false, foreign_key: true
      t.references :job_search_criteria, foreign_key: true
      t.string :status, default: "queued", null: false
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :duration_ms
      t.integer :listings_found, default: 0, null: false
      t.integer :new_listings, default: 0, null: false
      t.jsonb :error_details, default: {}, null: false

      t.timestamps
    end

    add_index :job_scan_runs, [ :job_source_id, :status ]
    add_index :job_scan_runs, :status
  end
end
