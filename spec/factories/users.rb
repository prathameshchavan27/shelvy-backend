FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { "test@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
