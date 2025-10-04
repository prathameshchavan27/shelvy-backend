FactoryBot.define do
  factory :bundled_product do
    bundle { nil }
    component { nil }
    quantity { 1 }
  end
end
