class AddBrandToProduct < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :brand, :string, default: "NA", null: false
    change_column_default :products, :brand, from: "NA", to: nil
  end
end
