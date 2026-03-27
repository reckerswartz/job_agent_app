class AddModelCapabilitiesToLlmModels < ActiveRecord::Migration[8.1]
  def change
    add_column :llm_models, :model_type, :string, default: "text", null: false
    add_column :llm_models, :max_images, :integer
    add_column :llm_models, :context_window, :integer
    add_column :llm_models, :role, :string
    add_index :llm_models, :role
    add_index :llm_models, :model_type
  end
end
