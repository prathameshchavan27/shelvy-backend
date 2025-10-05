class CreateInventorySummaries < ActiveRecord::Migration[7.2]
  def change
    create_table :inventory_summaries do |t|
      t.references :product, null: false, foreign_key: true
      t.references :inventory_location, null: false, foreign_key: true
      t.integer :quantity_on_hand
      t.integer :reserved_quantity

      t.timestamps
    end
  end
end
