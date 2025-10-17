FactoryBot.define do
  factory :audit_log do
    user { nil }
    action_type { "MyString" }
    object_type { "MyString" }
    object_id { 1 }
    change_log { "" }
  end
end
