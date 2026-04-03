class AddOwnedByToLlmModels < ActiveRecord::Migration[8.1]
  def change
    add_column :llm_models, :owned_by, :string
  end
end
