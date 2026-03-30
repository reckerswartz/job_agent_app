class CreateJobSources < ActiveRecord::Migration[8.1]
  def change
    create_table :job_sources do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :platform, null: false
      t.string :base_url
      t.boolean :enabled, default: true, null: false
      t.jsonb :credentials, default: {}, null: false
      t.jsonb :config, default: {}, null: false
      t.datetime :last_scanned_at
      t.integer :scan_interval_hours, default: 6, null: false
      t.string :status, default: "active", null: false

      t.timestamps
    end

    add_index :job_sources, [ :user_id, :platform ]
    add_index :job_sources, [ :user_id, :enabled ]
  end
end
