FactoryBot.define do
  factory :product_variant do
    association :product
    name { "Size" }
    value { "M" }
    price_modifier { 0 }
    stock { 10 }
  end
end
