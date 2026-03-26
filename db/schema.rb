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

ActiveRecord::Schema[8.1].define(version: 2026_03_26_205751) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "friends", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name", null: false
    t.string "phone"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "email"], name: "index_friends_on_user_id_and_email", unique: true
    t.index ["user_id"], name: "index_friends_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.integer "category", default: 0, null: false
    t.string "cover_image_url"
    t.datetime "created_at", null: false
    t.text "notes"
    t.string "platform"
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "category"], name: "index_items_on_user_id_and_category"
    t.index ["user_id", "status"], name: "index_items_on_user_id_and_status"
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "loans", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "expected_return_date"
    t.bigint "friend_id", null: false
    t.bigint "item_id", null: false
    t.date "loan_date", null: false
    t.datetime "returned_at"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["friend_id", "returned_at"], name: "index_loans_on_friend_id_and_returned_at"
    t.index ["friend_id"], name: "index_loans_on_friend_id"
    t.index ["item_id", "returned_at"], name: "index_loans_on_item_id_and_returned_at"
    t.index ["item_id"], name: "index_loans_on_item_id"
    t.index ["user_id", "returned_at"], name: "index_loans_on_user_id_and_returned_at"
    t.index ["user_id"], name: "index_loans_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "friends", "users"
  add_foreign_key "items", "users"
  add_foreign_key "loans", "friends"
  add_foreign_key "loans", "items"
  add_foreign_key "loans", "users"
end
