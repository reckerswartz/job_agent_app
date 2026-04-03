class CreateCoverLetters < ActiveRecord::Migration[8.1]
  def change
    create_table :cover_letters do |t|
      t.references :job_listing, null: false, foreign_key: true
      t.references :profile, null: false, foreign_key: true
      t.text :content, null: false
      t.string :tone
      t.string :status

      t.timestamps
    end
  end
end
