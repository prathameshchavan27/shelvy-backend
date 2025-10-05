FactoryBot.define do
  factory :inventory_movement do
    inventory_summary { nil }
    transfer_from_id { 1 }
    transfer_to_id { 1 }
    quantity_moved { 1 }
    bundle_id { 1 }
  end
end
