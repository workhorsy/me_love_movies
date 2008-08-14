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

ActiveRecord::Schema.define(:version => 6) do

  create_table "ratings", :force => true do |t|
    t.string "name"
    t.string "abbreviation"
  end

  create_table "sexes", :force => true do |t|
    t.string "name"
    t.string "abbreviation"
  end

  create_table "title_ratings", :force => true do |t|
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
  end

end
