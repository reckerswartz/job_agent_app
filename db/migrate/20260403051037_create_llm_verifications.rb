class CreateLlmVerifications < ActiveRecord::Migration[8.1]
  def change
    create_table :llm_verifications do |t|
      t.references :llm_model, null: false, foreign_key: true
      t.string :status, default: "pending", null: false
      t.text :input_payload
      t.text :response_payload
      t.integer :latency_ms
      t.text :error_message

      t.timestamps
    end
  end
end
