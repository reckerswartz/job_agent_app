class CreateLlmProviders < ActiveRecord::Migration[8.1]
  def change
    create_table :llm_providers do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :adapter, null: false
      t.string :base_url, null: false
      t.string :api_key_setting
      t.boolean :active, default: true, null: false
      t.jsonb :settings, default: {}, null: false

      t.timestamps
    end

    add_index :llm_providers, :slug, unique: true
    add_index :llm_providers, :active
  end
end
