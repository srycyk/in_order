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

ActiveRecord::Schema.define(version: 2019_08_14_125234) do

  create_table "in_order_elements", force: :cascade do |t|
    t.string "scope"
    t.string "owner_type"
    t.integer "owner_id"
    t.string "subject_type"
    t.integer "subject_id"
    t.integer "element_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["element_id"], name: "index_in_order_elements_on_element_id"
    t.index ["owner_type", "owner_id"], name: "index_in_order_elements_on_owner_type_and_owner_id"
    t.index ["scope"], name: "index_in_order_elements_on_scope"
    t.index ["subject_type", "subject_id"], name: "index_in_order_elements_on_subject_type_and_subject_id"
  end

  create_table "owners", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_owners_on_name"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_subjects_on_name"
  end

end
