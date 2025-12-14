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

ActiveRecord::Schema[8.1].define(version: 2025_12_10_112154) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "client_needs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "client_id", null: false
    t.datetime "created_at", null: false
    t.time "end_time", null: false
    t.uuid "office_id", null: false
    t.integer "shift_type", null: false
    t.integer "slots", null: false
    t.time "start_time", null: false
    t.datetime "updated_at", null: false
    t.integer "week", null: false
    t.index ["client_id"], name: "index_client_needs_on_client_id"
    t.index ["office_id"], name: "index_client_needs_on_office_id"
  end

  create_table "clients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.float "latitude"
    t.float "longitude"
    t.string "name", null: false
    t.uuid "office_id", null: false
    t.uuid "team_id", null: false
    t.datetime "updated_at", null: false
    t.index ["office_id"], name: "index_clients_on_office_id"
    t.index ["team_id"], name: "index_clients_on_team_id"
  end

  create_table "entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_read_at"
    t.uuid "office_id", null: false
    t.uuid "room_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["office_id"], name: "index_entries_on_office_id"
    t.index ["room_id", "user_id"], name: "index_entries_on_room_id_and_user_id", unique: true
    t.index ["room_id"], name: "index_entries_on_room_id"
    t.index ["user_id"], name: "index_entries_on_user_id"
  end

  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.uuid "office_id", null: false
    t.uuid "room_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["office_id"], name: "index_messages_on_office_id"
    t.index ["room_id"], name: "index_messages_on_room_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "offices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "cancel_at_period_end"
    t.datetime "created_at", null: false
    t.datetime "current_period_end"
    t.string "name", default: "未設定会社名", null: false
    t.string "stripe_customer_id"
    t.string "stripe_subscription_id"
    t.string "subscription_status"
    t.datetime "updated_at", null: false
  end

  create_table "rooms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.uuid "office_id", null: false
    t.datetime "updated_at", null: false
    t.index ["office_id"], name: "index_rooms_on_office_id"
  end

  create_table "shifts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "client_id", null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.time "end_time", null: false
    t.boolean "is_escort", default: false
    t.string "note"
    t.uuid "office_id", null: false
    t.integer "shift_type"
    t.time "start_time", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.integer "work_status", default: 0
    t.index ["client_id"], name: "index_shifts_on_client_id"
    t.index ["office_id"], name: "index_shifts_on_office_id"
    t.index ["user_id"], name: "index_shifts_on_user_id"
  end

  create_table "teams", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", default: "未設定部署名", null: false
    t.uuid "office_id", null: false
    t.datetime "updated_at", null: false
    t.index ["office_id"], name: "index_teams_on_office_id"
  end

  create_table "user_clients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "client_id", null: false
    t.datetime "created_at", null: false
    t.string "note"
    t.uuid "office_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["client_id", "user_id"], name: "index_user_clients_on_client_id_and_user_id", unique: true
    t.index ["client_id"], name: "index_user_clients_on_client_id"
    t.index ["office_id"], name: "index_user_clients_on_office_id"
    t.index ["user_id"], name: "index_user_clients_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "address"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.integer "consumed_timestep"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "invitation_accepted_at"
    t.datetime "invitation_created_at"
    t.integer "invitation_limit"
    t.datetime "invitation_sent_at"
    t.string "invitation_token"
    t.integer "invitations_count", default: 0
    t.uuid "invited_by_id"
    t.string "invited_by_type"
    t.float "latitude"
    t.datetime "locked_at"
    t.float "longitude"
    t.string "name", null: false
    t.uuid "office_id", null: false
    t.boolean "otp_required_for_login"
    t.string "otp_secret"
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.integer "second_factor_attempts_count"
    t.uuid "team_id", null: false
    t.string "uid"
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["office_id"], name: "index_users_on_office_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["team_id"], name: "index_users_on_team_id"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "client_needs", "clients"
  add_foreign_key "client_needs", "offices"
  add_foreign_key "clients", "offices"
  add_foreign_key "clients", "teams"
  add_foreign_key "entries", "offices"
  add_foreign_key "entries", "rooms"
  add_foreign_key "entries", "users"
  add_foreign_key "messages", "offices"
  add_foreign_key "messages", "rooms"
  add_foreign_key "messages", "users"
  add_foreign_key "rooms", "offices"
  add_foreign_key "shifts", "clients"
  add_foreign_key "shifts", "offices"
  add_foreign_key "shifts", "users"
  add_foreign_key "teams", "offices"
  add_foreign_key "user_clients", "clients"
  add_foreign_key "user_clients", "offices"
  add_foreign_key "user_clients", "users"
  add_foreign_key "users", "offices"
  add_foreign_key "users", "teams"
end
