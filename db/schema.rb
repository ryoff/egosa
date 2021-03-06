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

ActiveRecord::Schema.define(version: 20170508082807) do

  create_table "tweets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.bigint "since_id", default: 0, null: false, unsigned: true
    t.string "search_word", limit: 100
    t.string "name", limit: 100
    t.string "full_text", limit: 500
    t.string "uri", limit: 1000
    t.datetime "tweet_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["search_word"], name: "index_tweets_on_search_word", length: { search_word: 10 }
  end

end
