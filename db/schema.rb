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

ActiveRecord::Schema[8.1].define(version: 2026_03_27_093708) do
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

  create_table "job_listings", force: :cascade do |t|
    t.string "company"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "employment_type"
    t.datetime "expires_at"
    t.string "external_id"
    t.bigint "job_source_id", null: false
    t.string "location"
    t.integer "match_score"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "posted_at"
    t.jsonb "raw_data", default: {}, null: false
    t.string "remote_type"
    t.text "requirements"
    t.string "salary_range"
    t.string "status", default: "new", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["job_source_id", "external_id"], name: "index_job_listings_on_job_source_id_and_external_id", unique: true
    t.index ["job_source_id", "status"], name: "index_job_listings_on_job_source_id_and_status"
    t.index ["job_source_id"], name: "index_job_listings_on_job_source_id"
    t.index ["match_score"], name: "index_job_listings_on_match_score"
    t.index ["status"], name: "index_job_listings_on_status"
  end

  create_table "job_scan_runs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "duration_ms"
    t.jsonb "error_details", default: {}, null: false
    t.datetime "finished_at"
    t.bigint "job_search_criteria_id"
    t.bigint "job_source_id", null: false
    t.integer "listings_found", default: 0, null: false
    t.integer "new_listings", default: 0, null: false
    t.datetime "started_at"
    t.string "status", default: "queued", null: false
    t.datetime "updated_at", null: false
    t.index ["job_search_criteria_id"], name: "index_job_scan_runs_on_job_search_criteria_id"
    t.index ["job_source_id", "status"], name: "index_job_scan_runs_on_job_source_id_and_status"
    t.index ["job_source_id"], name: "index_job_scan_runs_on_job_source_id"
    t.index ["status"], name: "index_job_scan_runs_on_status"
  end

  create_table "job_search_criteria", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "excluded_companies"
    t.string "experience_level"
    t.boolean "is_default", default: false, null: false
    t.string "job_type", default: "full_time", null: false
    t.string "keywords"
    t.string "location"
    t.string "name", null: false
    t.string "remote_preference", default: "any", null: false
    t.integer "salary_max"
    t.integer "salary_min"
    t.jsonb "settings", default: {}, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "is_default"], name: "index_job_search_criteria_on_user_id_and_is_default"
    t.index ["user_id"], name: "index_job_search_criteria_on_user_id"
  end

  create_table "job_sources", force: :cascade do |t|
    t.string "base_url"
    t.jsonb "config", default: {}, null: false
    t.datetime "created_at", null: false
    t.jsonb "credentials", default: {}, null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "last_scanned_at"
    t.string "name", null: false
    t.string "platform", null: false
    t.integer "scan_interval_hours", default: 6, null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "enabled"], name: "index_job_sources_on_user_id_and_enabled"
    t.index ["user_id", "platform"], name: "index_job_sources_on_user_id_and_platform"
    t.index ["user_id"], name: "index_job_sources_on_user_id"
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

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "job_listings", "job_sources"
  add_foreign_key "job_scan_runs", "job_search_criteria", column: "job_search_criteria_id"
  add_foreign_key "job_scan_runs", "job_sources"
  add_foreign_key "job_search_criteria", "users"
  add_foreign_key "job_sources", "users"
  add_foreign_key "profile_entries", "profile_sections"
  add_foreign_key "profile_sections", "profiles"
  add_foreign_key "profiles", "users"
end
