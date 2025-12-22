FactoryBot.define do
  factory :inventory_summary do
    product { nil }
    inventory_location { nil }
    quantity_on_hand { 1 }
    reserved_quantity { 1 }
  end
end
