class CreateJobSearchCriteria < ActiveRecord::Migration[8.1]
  def change
    create_table :job_search_criteria do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.boolean :is_default, default: false, null: false
      t.string :keywords
      t.string :location
      t.string :remote_preference, default: "any", null: false
      t.string :experience_level
      t.integer :salary_min
      t.integer :salary_max
      t.string :job_type, default: "full_time", null: false
      t.text :excluded_companies
      t.jsonb :settings, default: {}, null: false

      t.timestamps
    end

    add_index :job_search_criteria, [ :user_id, :is_default ]
  end
end
