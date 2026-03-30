class CreateApplicationSteps < ActiveRecord::Migration[8.1]
  def change
    create_table :application_steps do |t|
      t.references :job_application, null: false, foreign_key: true
      t.integer :step_number, default: 0, null: false
      t.string :action, null: false
      t.string :status, default: "pending", null: false
      t.jsonb :input_data, default: {}, null: false
      t.jsonb :output_data, default: {}, null: false
      t.text :error_message
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end

    add_index :application_steps, [ :job_application_id, :step_number ]
  end
end
