class CreateInventoryLocations < ActiveRecord::Migration[7.2]
  def change
    create_table :inventory_locations do |t|
      t.string :storage_id
      t.integer :unique_item_limits
      t.integer :capacity, default: 100
      t.references :warehouse, null: false, foreign_key: true

      t.timestamps
    end
  end
end
