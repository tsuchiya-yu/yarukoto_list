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

ActiveRecord::Schema[7.1].define(version: 2024_05_18_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "template_items", force: :cascade do |t|
    t.bigint "template_id", null: false
    t.string "title", null: false
    t.text "description"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["template_id", "position"], name: "index_template_items_on_template_id_and_position"
    t.index ["template_id"], name: "index_template_items_on_template_id"
  end

  create_table "template_ratings", force: :cascade do |t|
    t.bigint "template_id", null: false
    t.bigint "user_id", null: false
    t.integer "score", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["template_id", "user_id"], name: "index_template_ratings_on_template_id_and_user_id", unique: true
    t.index ["template_id"], name: "index_template_ratings_on_template_id"
    t.index ["user_id"], name: "index_template_ratings_on_user_id"
  end

  create_table "template_reviews", force: :cascade do |t|
    t.bigint "template_id", null: false
    t.bigint "user_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["template_id"], name: "index_template_reviews_on_template_id"
    t.index ["template_id", "user_id"], name: "index_template_reviews_on_template_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_template_reviews_on_user_id"
  end

  create_table "templates", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.text "author_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_templates_on_user_id"
  end

  create_table "user_list_items", force: :cascade do |t|
    t.bigint "user_list_id", null: false
    t.bigint "template_item_id"
    t.string "title", null: false
    t.text "description"
    t.boolean "completed", default: false, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["template_item_id"], name: "index_user_list_items_on_template_item_id"
    t.index ["user_list_id", "position"], name: "index_user_list_items_on_user_list_id_and_position"
    t.index ["user_list_id"], name: "index_user_list_items_on_user_list_id"
  end

  create_table "user_lists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "template_id", null: false
    t.string "title", null: false
    t.text "description"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["template_id"], name: "index_user_lists_on_template_id"
    t.index ["user_id", "position"], name: "index_user_lists_on_user_id_and_position"
    t.index ["user_id"], name: "index_user_lists_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "template_items", "templates"
  add_foreign_key "template_ratings", "templates"
  add_foreign_key "template_ratings", "users"
  add_foreign_key "template_reviews", "templates"
  add_foreign_key "template_reviews", "users"
  add_foreign_key "templates", "users", on_delete: :cascade
  add_foreign_key "user_list_items", "template_items", on_delete: :nullify
  add_foreign_key "user_list_items", "user_lists"
  add_foreign_key "user_lists", "templates"
  add_foreign_key "user_lists", "users"
end
