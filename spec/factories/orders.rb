FactoryBot.define do
  factory :order do
    association :user, factory: [:user, :customer]
    association :store
    status { "pending" }
    payment_method { "cash_on_delivery" }
    subtotal { 500 }
    delivery_fee { 100 }
    total { 600 }
  end
end
