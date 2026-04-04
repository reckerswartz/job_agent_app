class CreateActivityLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action, null: false
      t.string :category
      t.text :description
      t.string :trackable_type
      t.bigint :trackable_id
      t.jsonb :metadata, default: {}
      t.string :ip_address

      t.timestamps
    end
    add_index :activity_logs, [ :user_id, :created_at ]
    add_index :activity_logs, [ :trackable_type, :trackable_id ]
  end
end
