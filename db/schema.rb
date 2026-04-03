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

ActiveRecord::Schema[8.1].define(version: 2026_04_03_163029) do
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

  create_table "application_steps", force: :cascade do |t|
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.text "error_message"
    t.datetime "finished_at"
    t.jsonb "input_data", default: {}, null: false
    t.bigint "job_application_id", null: false
    t.jsonb "output_data", default: {}, null: false
    t.datetime "started_at"
    t.string "status", default: "pending", null: false
    t.integer "step_number", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["job_application_id", "step_number"], name: "index_application_steps_on_job_application_id_and_step_number"
    t.index ["job_application_id"], name: "index_application_steps_on_job_application_id"
  end

  create_table "interventions", force: :cascade do |t|
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.string "intervention_type", null: false
    t.bigint "interventionable_id", null: false
    t.string "interventionable_type", null: false
    t.datetime "resolved_at"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.jsonb "user_input", default: {}, null: false
    t.index ["interventionable_type", "interventionable_id"], name: "index_interventions_on_interventionable"
    t.index ["status"], name: "index_interventions_on_status"
    t.index ["user_id", "status"], name: "index_interventions_on_user_id_and_status"
    t.index ["user_id"], name: "index_interventions_on_user_id"
  end

  create_table "job_applications", force: :cascade do |t|
    t.datetime "applied_at"
    t.datetime "created_at", null: false
    t.jsonb "error_details", default: {}, null: false
    t.jsonb "form_data_used", default: {}, null: false
    t.bigint "job_listing_id", null: false
    t.jsonb "metadata", default: {}, null: false
    t.text "notes"
    t.bigint "profile_id", null: false
    t.string "status", default: "queued", null: false
    t.datetime "updated_at", null: false
    t.index ["job_listing_id"], name: "index_job_applications_on_job_listing_id", unique: true
    t.index ["profile_id"], name: "index_job_applications_on_profile_id"
    t.index ["status"], name: "index_job_applications_on_status"
  end

  create_table "job_listings", force: :cascade do |t|
    t.string "application_url"
    t.string "company"
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "easy_apply", default: false
    t.string "employment_type"
    t.datetime "expires_at"
    t.string "external_id"
    t.bigint "job_source_id", null: false
    t.string "location"
    t.jsonb "match_breakdown", default: {}
    t.integer "match_score"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "posted_at"
    t.jsonb "raw_data", default: {}, null: false
    t.string "remote_type"
    t.text "requirements"
    t.boolean "resume_upload_supported", default: false
    t.string "salary_range"
    t.string "status", default: "new", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["easy_apply"], name: "index_job_listings_on_easy_apply"
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

  create_table "llm_interactions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "feature_name", null: false
    t.integer "latency_ms"
    t.bigint "llm_model_id"
    t.bigint "llm_provider_id"
    t.jsonb "metadata", default: {}, null: false
    t.bigint "profile_id"
    t.text "prompt"
    t.text "response"
    t.string "status", default: "pending", null: false
    t.jsonb "token_usage", default: {}, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["created_at"], name: "index_llm_interactions_on_created_at"
    t.index ["feature_name"], name: "index_llm_interactions_on_feature_name"
    t.index ["llm_model_id"], name: "index_llm_interactions_on_llm_model_id"
    t.index ["llm_provider_id"], name: "index_llm_interactions_on_llm_provider_id"
    t.index ["profile_id"], name: "index_llm_interactions_on_profile_id"
    t.index ["status"], name: "index_llm_interactions_on_status"
    t.index ["user_id"], name: "index_llm_interactions_on_user_id"
  end

  create_table "llm_models", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "context_window"
    t.datetime "created_at", null: false
    t.string "identifier", null: false
    t.datetime "last_verified_at"
    t.bigint "llm_provider_id", null: false
    t.integer "max_images"
    t.string "model_type", default: "text", null: false
    t.string "name", null: false
    t.string "owned_by"
    t.integer "priority", default: 0, null: false
    t.string "role"
    t.jsonb "settings", default: {}, null: false
    t.boolean "supports_text", default: true, null: false
    t.boolean "supports_vision", default: false, null: false
    t.datetime "updated_at", null: false
    t.string "verification_status", default: "untested"
    t.index ["active"], name: "index_llm_models_on_active"
    t.index ["llm_provider_id", "identifier"], name: "index_llm_models_on_llm_provider_id_and_identifier", unique: true
    t.index ["llm_provider_id"], name: "index_llm_models_on_llm_provider_id"
    t.index ["model_type"], name: "index_llm_models_on_model_type"
    t.index ["role"], name: "index_llm_models_on_role"
  end

  create_table "llm_providers", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "adapter", null: false
    t.string "api_key_setting"
    t.string "base_url", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.jsonb "settings", default: {}, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_llm_providers_on_active"
    t.index ["slug"], name: "index_llm_providers_on_slug", unique: true
  end

  create_table "llm_verifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error_message"
    t.text "input_payload"
    t.integer "latency_ms"
    t.bigint "llm_model_id", null: false
    t.text "response_payload"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["llm_model_id"], name: "index_llm_verifications_on_llm_model_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "action_url"
    t.text "body"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "read_at"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
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
    t.string "processing_status", default: "idle", null: false
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
    t.string "api_token"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.jsonb "notification_settings", default: {"email_new_matches" => true, "email_interventions" => true, "email_scan_completed" => true, "email_application_status" => true}, null: false
    t.boolean "onboarding_completed", default: false, null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "webhook_endpoints", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.jsonb "events", default: []
    t.string "secret"
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_webhook_endpoints_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "application_steps", "job_applications"
  add_foreign_key "interventions", "users"
  add_foreign_key "job_applications", "job_listings"
  add_foreign_key "job_applications", "profiles"
  add_foreign_key "job_listings", "job_sources"
  add_foreign_key "job_scan_runs", "job_search_criteria", column: "job_search_criteria_id"
  add_foreign_key "job_scan_runs", "job_sources"
  add_foreign_key "job_search_criteria", "users"
  add_foreign_key "job_sources", "users"
  add_foreign_key "llm_interactions", "llm_models"
  add_foreign_key "llm_interactions", "llm_providers"
  add_foreign_key "llm_interactions", "profiles"
  add_foreign_key "llm_interactions", "users"
  add_foreign_key "llm_models", "llm_providers"
  add_foreign_key "llm_verifications", "llm_models"
  add_foreign_key "notifications", "users"
  add_foreign_key "profile_entries", "profile_sections"
  add_foreign_key "profile_sections", "profiles"
  add_foreign_key "profiles", "users"
  add_foreign_key "webhook_endpoints", "users"
end
