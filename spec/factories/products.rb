FactoryBot.define do
  factory :product do
    sku { "MyString" }
    name { "MyString" }
    brand { "Test" }
    description { "MyText" }
    price { "9.99" }
    is_bundle { false }
    metadata { "" }
    created_by_user { nil }
  end
end
