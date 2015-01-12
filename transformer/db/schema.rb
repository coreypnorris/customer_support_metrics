# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150111203832) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "conversation_metrics", id: false, force: :cascade do |t|
    t.integer  "id",                      limit: 8
    t.string   "url"
    t.datetime "created_at"
    t.integer  "first_response_duration", limit: 8
    t.string   "status"
    t.boolean  "during_business_hours"
    t.boolean  "special_case"
    t.integer  "started_by",              limit: 8
  end

  create_table "conversation_tags", force: :cascade do |t|
    t.integer "conversation_id", limit: 8
    t.integer "tag_id"
  end

  create_table "conversation_threads", id: false, force: :cascade do |t|
    t.integer  "id",               limit: 8
    t.string   "thread_type"
    t.integer  "assigned_to_id",   limit: 8
    t.string   "status"
    t.datetime "created_at"
    t.datetime "opened_at"
    t.integer  "creator_id",       limit: 8
    t.string   "source"
    t.string   "action_type"
    t.integer  "action_source_id"
    t.string   "from_mailbox"
    t.string   "state"
    t.integer  "customer_id",      limit: 8
    t.text     "body"
    t.text     "to"
    t.text     "cc"
    t.text     "bcc"
    t.integer  "conversation_id",  limit: 8
  end

  create_table "conversations", id: false, force: :cascade do |t|
    t.integer  "id",                limit: 8
    t.integer  "owner_id",          limit: 8
    t.integer  "customer_id",       limit: 8
    t.integer  "creator_id",        limit: 8
    t.integer  "closer_id",         limit: 8
    t.string   "conversation_type"
    t.boolean  "is_draft"
    t.integer  "number",            limit: 8
    t.integer  "thread_count"
    t.string   "status"
    t.string   "subject"
    t.string   "preview"
    t.datetime "closed_at"
    t.string   "cc"
    t.string   "bcc"
    t.string   "source"
    t.string   "mailbox"
    t.datetime "created_at"
    t.datetime "modified_at"
  end

  create_table "people", id: false, force: :cascade do |t|
    t.integer "id",          limit: 8
    t.string  "first_name"
    t.string  "last_name"
    t.string  "email"
    t.string  "phone"
    t.string  "person_type"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
  end

end
