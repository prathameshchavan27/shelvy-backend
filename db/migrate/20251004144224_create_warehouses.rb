class CreateWarehouses < ActiveRecord::Migration[7.2]
  def change
    create_table :warehouses do |t|
      t.string :name, null: false
      t.string :address, null: false

      t.timestamps
    end
  end
end
