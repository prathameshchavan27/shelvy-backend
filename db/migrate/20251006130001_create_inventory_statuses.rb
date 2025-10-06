class CreateInventoryStatuses < ActiveRecord::Migration[7.2]
  def change
    create_table :inventory_statuses do |t|
      t.string :name

      t.timestamps
    end
    add_index :inventory_statuses, :name, unique: true
  end
end
