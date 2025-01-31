FactoryBot.define do
  factory :cart_item do
    association :cart
    association :product
    quantity { 1 }
    unit_price { product.price }
    total_price { quantity * unit_price }
  end
end
