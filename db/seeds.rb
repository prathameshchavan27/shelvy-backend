puts "🌱 Seeding database..."

# --- Clear existing data (optional, only for dev) ---
InventoryMovement.destroy_all
InventorySummary.destroy_all
InventoryStatus.destroy_all
Product.destroy_all
InventoryLocation.destroy_all
Warehouse.destroy_all
User.destroy_all

# --- Users ---
user = User.create!(
  name: "Admin User",
  email: "admin@example.com",
  password: "password"
)
puts "👤 Created user: #{user.name}"

# --- Warehouses ---
warehouse = Warehouse.create!(
  name: "Main Warehouse",
  address: "123 Industrial Area, Pune"
)
puts "🏭 Created warehouse: #{warehouse.name}"

# --- Inventory Locations ---
bin1 = InventoryLocation.create!(storage_id: "BIN-01", warehouse: warehouse, unique_item_limits: 5, capacity: 100)
bin2 = InventoryLocation.create!(storage_id: "BIN-02", warehouse: warehouse, unique_item_limits: 5, capacity: 100)
puts "📦 Created locations: #{[ bin1.storage_id, bin2.storage_id ].join(', ')}"

# --- Inventory Statuses ---
sellable = InventoryStatus.create!(name: "Sellable")
unsellable = InventoryStatus.create!(name: "Unsellable")
damaged = InventoryStatus.create!(name: "Damaged")
puts "🏷️ Seeded statuses: Sellable, Unsellable, Damaged"

# --- Products ---
coffee = Product.create!(name: "Coffee", price: 10, created_by_user: user)
tea = Product.create!(name: "Tea", price: 8, created_by_user: user)
mug = Product.create!(name: "Mug", price: 5, created_by_user: user)
notebook = Product.create!(name: "Notebook", price: 15, created_by_user: user)

puts "☕ Created products: Coffee, Tea, Mug, Notebook"

# --- Bundles ---

# Coffee - Tea
coffee_tea_bundle = Product.create!(
  name: "B Coffee & Tea Bundle",
  is_bundle: true,
  price: coffee.price + tea.price,
  created_by_user: user
)
BundledProduct.create!(bundle: coffee_tea_bundle, component: coffee, quantity: 1)
BundledProduct.create!(bundle: coffee_tea_bundle, component: tea, quantity: 1)

# Coffee - Mug
coffee_mug_bundle = Product.create!(
  name: "B2 Mug & Coffee",
  is_bundle: true,
  price: coffee.price + mug.price,
  created_by_user: user
)
BundledProduct.create!(bundle: coffee_mug_bundle, component: coffee, quantity: 1)
BundledProduct.create!(bundle: coffee_mug_bundle, component: mug, quantity: 1)

# Tea - Mug
tea_mug_bundle = Product.create!(
  name: "B2 Tea & Mug Bundle",
  is_bundle: true,
  price: tea.price + mug.price,
  created_by_user: user
)
BundledProduct.create!(bundle: tea_mug_bundle, component: tea, quantity: 1)
BundledProduct.create!(bundle: tea_mug_bundle, component: mug, quantity: 1)

# Coffee - Tea - Mug
coffee_tea_mug_bundle = Product.create!(
  name: "B3 Tea, Coffee, Mug Bundle",
  is_bundle: true,
  price: coffee.price + tea.price + mug.price,
  created_by_user: user
)
BundledProduct.create!(bundle: coffee_tea_mug_bundle, component: coffee, quantity: 1)
BundledProduct.create!(bundle: coffee_tea_mug_bundle, component: tea, quantity: 1)
BundledProduct.create!(bundle: coffee_tea_mug_bundle, component: mug, quantity: 1)

puts "☕ Created bundle products: with Coffee, Tea, Mug, Notebook"

# --- Inventory Summaries ---
InventorySummary.create!(
  product: coffee,
  inventory_location: bin1,
  inventory_status: sellable,
  quantity_on_hand: 50,
  reserved_quantity: 5
)

InventorySummary.create!(
  product: tea,
  inventory_location: bin1,
  inventory_status: unsellable,
  quantity_on_hand: 30,
  reserved_quantity: 0
)

InventorySummary.create!(
  product: mug,
  inventory_location: bin1,
  inventory_status: sellable,
  quantity_on_hand: 100,
  reserved_quantity: 10
)

InventorySummary.create!(
  product: coffee,
  inventory_location: bin2,
  inventory_status: damaged,
  quantity_on_hand: 20,
  reserved_quantity: 2
)

InventorySummary.create!(
  product: notebook,
  inventory_location: bin2,
  inventory_status: sellable,
  quantity_on_hand: 40,
  reserved_quantity: 5
)

puts "📊 Created inventory summaries for products across bins"

# --- Inventory Movements ---
InventoryMovement.create!(
  inventory_summary: InventorySummary.find_by(product: coffee, inventory_location: bin1),
  transfer_from: bin1,
  transfer_to: bin2,
  quantity_moved: 10
)

puts "🚚 Recorded movement: 10 units of Coffee from BIN-01 → BIN-02"

puts "✅ Seeding complete!"
