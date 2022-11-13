# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_11_13_010000) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "node_data", force: :cascade do |t|
    t.bigint "node_id", null: false
    t.jsonb "holders", default: []
    t.jsonb "transfers", default: []
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["holders"], name: "index_node_data_on_holders", using: :gin
    t.index ["node_id"], name: "index_node_data_on_node_id"
    t.index ["transfers"], name: "index_node_data_on_transfers", using: :gin
  end

  create_table "nodes", force: :cascade do |t|
    t.string "address", null: false
    t.integer "address_type", null: false
    t.string "name"
    t.string "symbol"
    t.string "image_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "spam", default: false
    t.jsonb "meta", default: {}
    t.index ["address"], name: "index_nodes_on_address", unique: true
  end

  add_foreign_key "node_data", "nodes"
end
