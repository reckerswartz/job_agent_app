class CreateProfileSections < ActiveRecord::Migration[8.1]
  def change
    create_table :profile_sections do |t|
      t.references :profile, null: false, foreign_key: true
      t.string :section_type, null: false
      t.string :title, null: false
      t.integer :position, default: 0, null: false
      t.jsonb :settings, default: {}, null: false

      t.timestamps
    end

    add_index :profile_sections, [ :profile_id, :position ]
    add_index :profile_sections, [ :profile_id, :section_type ]
  end
end
