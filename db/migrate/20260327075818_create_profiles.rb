class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :headline
      t.text :summary, default: "", null: false
      t.jsonb :contact_details, default: {}, null: false
      t.jsonb :personal_details, default: {}, null: false
      t.jsonb :settings, default: {}, null: false
      t.string :source_mode, default: "scratch", null: false
      t.text :source_text
      t.string :status, default: "draft", null: false

      t.timestamps
    end

    add_index :profiles, [ :user_id, :status ]
  end
end
