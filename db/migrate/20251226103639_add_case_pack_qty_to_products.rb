class AddCasePackQtyToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :case_pack_qty, :integer, default: 1, null: false
  end
end
