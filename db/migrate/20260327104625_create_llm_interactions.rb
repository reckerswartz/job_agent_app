class CreateLlmInteractions < ActiveRecord::Migration[8.1]
  def change
    create_table :llm_interactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :profile, foreign_key: true
      t.references :llm_provider, foreign_key: true
      t.references :llm_model, foreign_key: true
      t.string :feature_name, null: false
      t.text :prompt
      t.text :response
      t.string :status, default: "pending", null: false
      t.jsonb :token_usage, default: {}, null: false
      t.integer :latency_ms
      t.jsonb :metadata, default: {}, null: false

      t.timestamps
    end

    add_index :llm_interactions, :feature_name
    add_index :llm_interactions, :status
    add_index :llm_interactions, :created_at
  end
end
