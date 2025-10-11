class RemoveInventoryLocationIdFromProducts < ActiveRecord::Migration[7.2]
  def up
    # 1️⃣ Optional: backup existing data (if you might need it)
    # execute "CREATE TABLE products_backup AS SELECT * FROM products"

    # 2️⃣ Remove foreign key & column safely
    remove_foreign_key :products, :inventory_locations if foreign_key_exists?(:products, :inventory_locations)
    remove_column :products, :inventory_location_id, :bigint
  end

  def down
    # rollback support
    add_column :products, :inventory_location_id, :bigint
    add_foreign_key :products, :inventory_locations
  end
end
