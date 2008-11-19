# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 23) do

  create_table "posters", :force => true do |t|
    t.integer "title_id"
    t.text    "small_image_file"
    t.text    "big_image_file"
    t.string  "product_id"
  end

  create_table "ratings", :force => true do |t|
    t.string "name"
    t.string "abbreviation"
  end

  create_table "sexes", :force => true do |t|
    t.string "name"
    t.string "abbreviation"
  end

  create_table "tags", :force => true do |t|
    t.string "name"
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
    t.integer  "character_dev"
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
    t.float    "avg_user_rating"
  end

  add_index "title_reviews", ["id"], :name => "index_title_reviews_on_id"

  create_table "title_tags", :force => true do |t|
    t.integer "tag_id"
    t.integer "title_id"
    t.integer "count"
  end

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
    t.float    "avg_action"
    t.float    "avg_comedy"
    t.float    "avg_drama"
    t.float    "avg_scifi"
    t.float    "avg_romance"
    t.float    "avg_musical"
    t.float    "avg_kids"
    t.float    "avg_adventure"
    t.float    "avg_mystery"
    t.float    "avg_suspense"
    t.float    "avg_horror"
    t.float    "avg_fantasy"
    t.float    "avg_tv"
    t.float    "avg_war"
    t.float    "avg_western"
    t.float    "avg_sports"
    t.float    "avg_premise"
    t.float    "avg_plot"
    t.float    "avg_music"
    t.float    "avg_acting"
    t.float    "avg_special_effects"
    t.float    "avg_pace"
    t.float    "avg_character_dev"
    t.float    "avg_cinematography"
    t.text     "data_source"
  end

  add_index "titles", ["id"], :name => "index_titles_on_id"
  add_index "titles", ["name"], :name => "index_titles_on_name"

  create_table "user_tags", :force => true do |t|
    t.integer "tag_id"
    t.integer "user_id"
    t.integer "title_id"
  end

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
    t.boolean  "is_email_activated", :default => false, :null => false
    t.boolean  "disabled"
    t.text     "disabled_reason"
  end

  add_index "users", ["id"], :name => "index_users_on_id"
  add_index "users", ["name"], :name => "index_users_on_name"

end
