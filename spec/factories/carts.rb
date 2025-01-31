FactoryBot.define do
  factory :shopping_cart, class: 'Cart' do
    status { 'active' }

    trait :abandoned do
      status { 'abandoned' }
      last_interaction_at { 8.days.ago }
    end

    trait :recently_abandoned do
      status { 'abandoned' }
      last_interaction_at { 2.days.ago }
    end
  end
end
