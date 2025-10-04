class CreateBundledProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :bundled_products do |t|
      t.references :bundle, null: false, foreign_key: { to_table: :products }
      t.references :component, null: false, foreign_key: { to_table: :products }
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end
    add_index :bundled_products, [ :bundle_id, :component_id ], unique: true
  end
end
