class CreateWebhookEndpoints < ActiveRecord::Migration[8.1]
  def change
    create_table :webhook_endpoints do |t|
      t.references :user, null: false, foreign_key: true
      t.string :url, null: false
      t.string :secret
      t.boolean :active, default: true, null: false
      t.jsonb :events, default: []
      t.timestamps
    end
  end
end
