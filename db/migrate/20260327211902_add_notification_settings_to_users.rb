class AddNotificationSettingsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :notification_settings, :jsonb, default: {
      "email_scan_completed" => true,
      "email_new_matches" => true,
      "email_application_status" => true,
      "email_interventions" => true
    }, null: false
  end
end
