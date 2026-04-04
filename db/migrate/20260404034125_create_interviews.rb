class CreateInterviews < ActiveRecord::Migration[8.1]
  def change
    create_table :interviews do |t|
      t.references :job_application, null: false, foreign_key: true
      t.string :stage, null: false
      t.datetime :scheduled_at
      t.string :interviewer_name
      t.string :location
      t.string :format
      t.text :notes
      t.text :prep_questions
      t.string :status, default: "scheduled", null: false
      t.integer :rating

      t.timestamps
    end
  end
end
