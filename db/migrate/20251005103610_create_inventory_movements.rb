class CreateInventoryMovements < ActiveRecord::Migration[7.2]
  def change
    create_table :inventory_movements do |t|
      t.references :inventory_summary, null: false, foreign_key: true
      t.integer :transfer_from_id
      t.integer :transfer_to_id
      t.integer :quantity_moved
      t.integer :bundle_id

      t.timestamps
    end
    add_foreign_key :inventory_movements, :inventory_locations, column: :transfer_from_id
    add_foreign_key :inventory_movements, :inventory_locations, column: :transfer_to_id
    add_foreign_key :inventory_movements, :products, column: :bundle_id
  end
end
