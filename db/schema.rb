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

ActiveRecord::Schema[7.0].define(version: 2024_02_11_182614) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "credit_lists", id: :string, force: :cascade do |t|
    t.json "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "movie_id"
    t.index ["movie_id"], name: "index_credit_lists_on_movie_id"
  end

  create_table "details", id: :string, force: :cascade do |t|
    t.json "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "movie_id"
    t.index ["movie_id"], name: "index_details_on_movie_id"
  end

  create_table "friendships", force: :cascade do |t|
    t.integer "user_a_id", null: false
    t.integer "user_b_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "movies", force: :cascade do |t|
    t.string "_id"
    t.string "title"
    t.string "poster"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "saved_graphs", force: :cascade do |t|
    t.json "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "request_ids"
    t.string "slug"
    t.text "existing", default: [], array: true
  end

  create_table "searches", force: :cascade do |t|
    t.string "term"
    t.json "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_movies", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "movie_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_user_movies_on_movie_id"
    t.index ["user_id"], name: "index_user_movies_on_user_id"
  end

  create_table "user_saved_graphs", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "saved_graph_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["saved_graph_id"], name: "index_user_saved_graphs_on_saved_graph_id"
    t.index ["user_id"], name: "index_user_saved_graphs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", null: false
    t.string "profile_img"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "user_movies", "movies"
  add_foreign_key "user_movies", "users"
end
