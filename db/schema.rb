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

ActiveRecord::Schema[7.2].define(version: 2025_10_11_145958) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bundled_products", force: :cascade do |t|
    t.bigint "bundle_id", null: false
    t.bigint "component_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bundle_id", "component_id"], name: "index_bundled_products_on_bundle_id_and_component_id", unique: true
    t.index ["bundle_id"], name: "index_bundled_products_on_bundle_id"
    t.index ["component_id"], name: "index_bundled_products_on_component_id"
  end

  create_table "inventory_locations", force: :cascade do |t|
    t.string "storage_id"
    t.integer "unique_item_limits"
    t.integer "capacity", default: 100
    t.bigint "warehouse_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["warehouse_id"], name: "index_inventory_locations_on_warehouse_id"
  end

  create_table "inventory_movements", force: :cascade do |t|
    t.bigint "inventory_summary_id", null: false
    t.integer "transfer_from_id"
    t.integer "transfer_to_id"
    t.integer "quantity_moved"
    t.integer "bundle_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_summary_id"], name: "index_inventory_movements_on_inventory_summary_id"
  end

  create_table "inventory_statuses", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_inventory_statuses_on_name", unique: true
  end

  create_table "inventory_summaries", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "inventory_location_id", null: false
    t.integer "quantity_on_hand"
    t.integer "reserved_quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "inventory_status_id", null: false
    t.index ["inventory_location_id"], name: "index_inventory_summaries_on_inventory_location_id"
    t.index ["inventory_status_id"], name: "index_inventory_summaries_on_inventory_status_id"
    t.index ["product_id"], name: "index_inventory_summaries_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "sku"
    t.string "name"
    t.text "description"
    t.decimal "price", precision: 10, scale: 2
    t.boolean "is_bundle", default: false
    t.jsonb "metadata", default: {}
    t.bigint "created_by_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_user_id"], name: "index_products_on_created_by_user_id"
    t.index ["sku"], name: "index_products_on_sku", unique: true
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
    t.string "name", null: false
    t.integer "role", default: 2, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "warehouses", force: :cascade do |t|
    t.string "name", null: false
    t.string "address", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "bundled_products", "products", column: "bundle_id"
  add_foreign_key "bundled_products", "products", column: "component_id"
  add_foreign_key "inventory_locations", "warehouses"
  add_foreign_key "inventory_movements", "inventory_locations", column: "transfer_from_id"
  add_foreign_key "inventory_movements", "inventory_locations", column: "transfer_to_id"
  add_foreign_key "inventory_movements", "inventory_summaries"
  add_foreign_key "inventory_movements", "products", column: "bundle_id"
  add_foreign_key "inventory_summaries", "inventory_locations"
  add_foreign_key "inventory_summaries", "inventory_statuses"
  add_foreign_key "inventory_summaries", "products"
  add_foreign_key "products", "users", column: "created_by_user_id"
end
