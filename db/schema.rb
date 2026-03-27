# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_27_082631) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "app_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.text "encrypted_value"
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_app_settings_on_key", unique: true
  end

  create_table "profile_entries", force: :cascade do |t|
    t.jsonb "content", default: {}, null: false
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.bigint "profile_section_id", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_section_id", "position"], name: "index_profile_entries_on_profile_section_id_and_position"
    t.index ["profile_section_id"], name: "index_profile_entries_on_profile_section_id"
  end

  create_table "profile_sections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.bigint "profile_id", null: false
    t.string "section_type", null: false
    t.jsonb "settings", default: {}, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id", "position"], name: "index_profile_sections_on_profile_id_and_position"
    t.index ["profile_id", "section_type"], name: "index_profile_sections_on_profile_id_and_section_type"
    t.index ["profile_id"], name: "index_profile_sections_on_profile_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.jsonb "contact_details", default: {}, null: false
    t.datetime "created_at", null: false
    t.string "headline"
    t.jsonb "personal_details", default: {}, null: false
    t.jsonb "settings", default: {}, null: false
    t.string "source_mode", default: "scratch", null: false
    t.text "source_text"
    t.string "status", default: "draft", null: false
    t.text "summary", default: "", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "status"], name: "index_profiles_on_user_id_and_status"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "profile_entries", "profile_sections"
  add_foreign_key "profile_sections", "profiles"
  add_foreign_key "profiles", "users"
  add_foreign_key "sessions", "users"
end
