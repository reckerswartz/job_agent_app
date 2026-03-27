class CreateLlmModels < ActiveRecord::Migration[8.1]
  def change
    create_table :llm_models do |t|
      t.references :llm_provider, null: false, foreign_key: true
      t.string :name, null: false
      t.string :identifier, null: false
      t.boolean :supports_text, default: true, null: false
      t.boolean :supports_vision, default: false, null: false
      t.boolean :active, default: true, null: false
      t.jsonb :settings, default: {}, null: false

      t.timestamps
    end

    add_index :llm_models, [:llm_provider_id, :identifier], unique: true
    add_index :llm_models, :active
  end
end
