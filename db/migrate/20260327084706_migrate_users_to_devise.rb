class MigrateUsersToDevise < ActiveRecord::Migration[8.1]
  def change
    # Rename columns to Devise conventions
    rename_column :users, :email_address, :email
    rename_column :users, :password_digest, :encrypted_password

    # Add Devise trackable columns
    add_column :users, :sign_in_count, :integer, default: 0, null: false
    add_column :users, :current_sign_in_at, :datetime
    add_column :users, :last_sign_in_at, :datetime
    add_column :users, :current_sign_in_ip, :string
    add_column :users, :last_sign_in_ip, :string

    # Add Devise recoverable columns
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime

    # Add Devise rememberable column
    add_column :users, :remember_created_at, :datetime

    # Add indexes
    add_index :users, :reset_password_token, unique: true

    # Drop the custom sessions table (replaced by Devise/Warden cookie sessions)
    drop_table :sessions do |t|
      t.bigint :user_id, null: false
      t.string :ip_address, null: false
      t.string :user_agent, null: false
      t.timestamps
    end
  end
end
