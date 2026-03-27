FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@test.com" }
    name { Faker::Name.name }
    password { "password123" }
    password_confirmation { "password123" }
    role { "customer" }

    trait :vendor do
      role { "vendor" }
      sequence(:email) { |n| "vendor#{n}@test.com" }
    end

    trait :admin do
      role { "admin" }
      sequence(:email) { |n| "admin#{n}@test.com" }
    end

    trait :customer do
      role { "customer" }
    end
  end
end
