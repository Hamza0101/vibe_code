FactoryBot.define do
  factory :store do
    association :user, factory: [:user, :vendor]
    sequence(:name) { |n| "Store #{n}" }
    category { "grocery" }
    city { "Lahore" }
    address { Faker::Address.street_address }
    phone { "03001234567" }
    description { Faker::Lorem.sentence }
    verified { true }
    featured { false }

    trait :pharmacy do
      category { "pharmacy" }
    end

    trait :clothing do
      category { "clothing" }
    end

    trait :featured do
      featured { true }
    end

    trait :unverified do
      verified { false }
    end
  end
end
