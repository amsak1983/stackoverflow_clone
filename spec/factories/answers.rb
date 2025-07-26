FactoryBot.define do
  factory :answer do
    sequence(:body) { |n| "This is a sample answer #{n}." }
    best { false }
    association :question
    association :user

    trait :invalid do
      body { nil }
    end

    trait :best do
      best { true }
    end
  end
end
