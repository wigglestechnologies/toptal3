# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_10_06_133537) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "allowed_tokens", force: :cascade do |t|
    t.string "encrypted_token", null: false
    t.bigint "user_id", null: false
    t.string "ip", limit: 150
    t.string "os", limit: 250
    t.string "user_agent", limit: 250
    t.string "platform", limit: 250
    t.string "browser", limit: 250
    t.datetime "expired_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["encrypted_token"], name: "index_allowed_tokens_on_encrypted_token", unique: true
  end

  create_table "joggings", force: :cascade do |t|
    t.date "date", null: false
    t.time "duration", null: false
    t.integer "distance", null: false
    t.integer "seconds"
    t.decimal "lon", precision: 10, scale: 6
    t.decimal "lat", precision: 10, scale: 6
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_joggings_on_user_id"
  end

  create_table "registration_details", force: :cascade do |t|
    t.string "token", limit: 255, null: false
    t.string "email", limit: 255, null: false
    t.datetime "valid_until", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_registration_details_on_email"
    t.index ["token"], name: "index_registration_details_on_token"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", limit: 250, null: false
    t.string "full_name", limit: 250
    t.integer "role", null: false
    t.boolean "active", default: false, null: false
    t.string "crypted_password", limit: 255
    t.string "salt", limit: 255
    t.string "reset_password_token"
    t.datetime "reset_password_email_sent_at"
    t.datetime "reset_password_token_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true, where: "(active IS TRUE)"
  end

  create_table "weathers", force: :cascade do |t|
    t.decimal "temp_c", precision: 5, scale: 2
    t.decimal "temp_f", precision: 5, scale: 2
    t.string "region"
    t.string "country"
    t.string "weather_type"
    t.integer "jogging_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jogging_id"], name: "index_weathers_on_jogging_id", unique: true
  end

  add_foreign_key "joggings", "users"
  add_foreign_key "weathers", "joggings"
end
