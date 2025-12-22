FactoryBot.define do
  factory :inventory_location do
    storage_id { "MyString" }
    unique_item_limits { 1 }
    warehouse { nil }
  end
end
