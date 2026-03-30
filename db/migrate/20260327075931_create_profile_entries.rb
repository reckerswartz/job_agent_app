class CreateProfileEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :profile_entries do |t|
      t.references :profile_section, null: false, foreign_key: true
      t.integer :position, default: 0, null: false
      t.jsonb :content, default: {}, null: false

      t.timestamps
    end

    add_index :profile_entries, [ :profile_section_id, :position ]
  end
end
