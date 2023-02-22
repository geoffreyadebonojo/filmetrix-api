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

ActiveRecord::Schema[7.0].define(version: 2023_02_22_005823) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "links", force: :cascade do |t|
    t.integer "movie_id"
    t.integer "person_id"
    t.string "roles", default: [], array: true
  end

  create_table "movies", force: :cascade do |t|
    t.boolean "adult"
    t.string "backdrop_path"
    t.text "belongs_to_collection", default: [], array: true
    t.integer "budget"
    t.json "genres", default: [], array: true
    t.string "homepage"
    t.string "title"
    t.string "imdb_id"
    t.string "original_language"
    t.string "original_title"
    t.text "overview"
    t.string "poster_path"
    t.json "production_companies", default: [], array: true
    t.json "production_countries", default: [], array: true
    t.string "media_type"
    t.integer "genre_ids", default: [], array: true
    t.float "popularity"
    t.date "release_date"
    t.integer "revenue"
    t.integer "runtime"
    t.json "spoken_languages", default: [], array: true
    t.string "status"
    t.string "tagline"
    t.boolean "video"
    t.float "vote_average"
    t.integer "vote_count"
  end

  create_table "people", force: :cascade do |t|
    t.boolean "adult"
    t.string "also_known_as", default: [], array: true
    t.string "biography"
    t.date "birthday"
    t.date "deathday"
    t.string "name"
    t.string "original_name"
    t.string "homepage"
    t.string "imdb_id"
    t.string "media_type"
    t.float "popularity"
    t.string "place_of_birth"
    t.integer "gender"
    t.string "known_for_department"
    t.string "profile_path"
  end

end
