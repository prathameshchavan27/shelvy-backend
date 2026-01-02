class AddBarcodeToProduct < ActiveRecord::Migration[7.2]
  def change
    # 1. Create the column
    add_column :products, :barcode, :string

    # 2. Tell Rails to "refresh" its knowledge of the Product columns
    # Without this, Product.first won't know the 'barcode' column exists yet
    Product.reset_column_information

    # 3. Fill the data
    Product.find_each do |product|
      identity = "#{product.name}#{product.brand}#{product.id}"
      barcode_val = Digest::SHA256.hexdigest(identity).to_i(16).to_s.first(12)

      product.update_column(:barcode, barcode_val)
    end

    # 4. Lock it down
    change_column_null :products, :barcode, false
    add_index :products, :barcode, unique: true
  end
end
