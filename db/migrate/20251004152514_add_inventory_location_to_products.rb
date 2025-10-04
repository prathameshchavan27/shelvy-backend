class AddInventoryLocationToProducts < ActiveRecord::Migration[7.2]
  def change
    add_reference :products, :inventory_location, null: false, foreign_key: true
  end
end
