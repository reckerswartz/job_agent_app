class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body
      t.string :category
      t.string :action_url
      t.datetime :read_at

      t.timestamps
    end
  end
end
