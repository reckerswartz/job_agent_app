class AddVerificationFieldsToLlmModels < ActiveRecord::Migration[8.1]
  def change
    add_column :llm_models, :last_verified_at, :datetime
    add_column :llm_models, :verification_status, :string, default: "untested"
    add_column :llm_models, :priority, :integer, default: 0, null: false
  end
end
