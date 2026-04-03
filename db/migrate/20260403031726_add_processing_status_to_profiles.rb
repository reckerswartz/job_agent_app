class AddProcessingStatusToProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :profiles, :processing_status, :string, default: "idle", null: false
  end
end
