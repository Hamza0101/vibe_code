FactoryBot.define do
  factory :subscription_plan do
    name { "Free" }
    price_pkr { 0 }
    product_limit { 20 }
    features { { "analytics" => false, "featured" => false, "sms" => false } }

    trait :free do
      name { "Free" }
      price_pkr { 0 }
      product_limit { 20 }
    end

    trait :starter do
      name { "Starter" }
      price_pkr { 1500 }
      product_limit { 100 }
      features { { "analytics" => true, "featured" => false, "sms" => false } }
    end

    trait :pro do
      name { "Pro" }
      price_pkr { 4000 }
      product_limit { nil }
      features { { "analytics" => true, "featured" => true, "sms" => true } }
    end
  end
end
