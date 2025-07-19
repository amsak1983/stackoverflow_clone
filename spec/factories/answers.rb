FactoryBot.define do
  factory :answer do
    body { 'This is a sample answer.' }
    association :question
    association :user

    trait :invalid do
      body { nil }
    end
  end
end
