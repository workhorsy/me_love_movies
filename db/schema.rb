# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 13) do

  create_table "ratings", :force => true do |t|
    t.string "name"
    t.string "abbreviation"
  end

  create_table "sexes", :force => true do |t|
    t.string "name"
    t.string "abbreviation"
  end

  create_table "title_ratings", :force => true do |t|
    t.integer  "title_id"
    t.integer  "action"
    t.integer  "comedy"
    t.integer  "drama"
    t.integer  "scifi"
    t.integer  "romance"
    t.integer  "musical"
    t.integer  "kids"
    t.integer  "adventure"
    t.integer  "mystery"
    t.integer  "suspense"
    t.integer  "horror"
    t.integer  "fantasy"
    t.integer  "tv"
    t.integer  "war"
    t.integer  "western"
    t.integer  "sports"
    t.integer  "premise"
    t.integer  "plot"
    t.integer  "music"
    t.integer  "acting"
    t.integer  "special_effects"
    t.integer  "pace"
    t.integer  "character_development"
    t.integer  "cinematography"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "title_ratings", ["id"], :name => "index_title_ratings_on_id"

  create_table "title_review_ratings", :force => true do |t|
    t.integer  "title_review_id"
    t.integer  "user_id"
    t.integer  "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "title_review_ratings", ["id"], :name => "index_title_review_ratings_on_id"

  create_table "title_reviews", :force => true do |t|
    t.integer  "user_id"
    t.integer  "title_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "avg_user_rating"
  end

  add_index "title_reviews", ["id"], :name => "index_title_reviews_on_id"

  create_table "titles", :force => true do |t|
    t.string   "name"
    t.date     "release_date"
    t.string   "source"
    t.string   "director"
    t.text     "cast"
    t.integer  "runtime"
    t.string   "rating"
    t.text     "premise"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "avg_action"
    t.integer  "avg_comedy"
    t.integer  "avg_drama"
    t.integer  "avg_scifi"
    t.integer  "avg_romance"
    t.integer  "avg_musical"
    t.integer  "avg_kids"
    t.integer  "avg_adventure"
    t.integer  "avg_mystery"
    t.integer  "avg_suspense"
    t.integer  "avg_horror"
    t.integer  "avg_fantasy"
    t.integer  "avg_tv"
    t.integer  "avg_war"
    t.integer  "avg_western"
    t.integer  "avg_sports"
    t.integer  "avg_premise"
    t.integer  "avg_plot"
    t.integer  "avg_music"
    t.integer  "avg_acting"
    t.integer  "avg_special_effects"
    t.integer  "avg_pace"
    t.integer  "avg_character_development"
    t.integer  "avg_cinematography"
  end

  add_index "titles", ["id"], :name => "index_titles_on_id"
  add_index "titles", ["name"], :name => "index_titles_on_name"

  create_table "user_types", :force => true do |t|
    t.string "name"
    t.string "abbreviation"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "user_name"
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "time_zone"
    t.integer  "year_of_birth"
    t.string   "gender"
    t.string   "email"
    t.string   "avatar_file"
    t.string   "user_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["id"], :name => "index_users_on_id"
  add_index "users", ["name"], :name => "index_users_on_name"

end
