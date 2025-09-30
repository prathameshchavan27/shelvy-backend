class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :sku
      t.string :name
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.boolean :is_bundle, default: false
      t.jsonb :metadata, default: {}
      t.references :created_by_user, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :products, :sku, unique: true
  end
end
