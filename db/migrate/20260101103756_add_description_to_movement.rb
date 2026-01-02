class AddDescriptionToMovement < ActiveRecord::Migration[7.2]
  def change
    add_column :inventory_movements, :description, :string
  end
end
