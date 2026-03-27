FactoryBot.define do
  factory :product do
    association :store
    sequence(:name) { |n| "Product #{n}" }
    description { Faker::Lorem.paragraph }
    price { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    stock { 50 }
    published { true }
    featured { false }

    trait :unpublished do
      published { false }
    end

    trait :out_of_stock do
      stock { 0 }
    end

    trait :featured do
      featured { true }
    end
  end
end
