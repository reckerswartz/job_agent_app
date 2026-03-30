class CreateInterventions < ActiveRecord::Migration[8.1]
  def change
    create_table :interventions do |t|
      t.references :interventionable, polymorphic: true, null: false
      t.string :intervention_type, null: false
      t.string :status, default: "pending", null: false
      t.jsonb :context, default: {}, null: false
      t.jsonb :user_input, default: {}, null: false
      t.datetime :resolved_at
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :interventions, [ :user_id, :status ]
    add_index :interventions, :status
  end
end
