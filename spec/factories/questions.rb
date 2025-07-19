FactoryBot.define do
  factory :question do
    sequence(:title) { |n| "Question Title #{n}" }
    sequence(:body) { |n| "Question Body #{n} with detailed content" }
    association :user

    trait :invalid do
      title { nil }
    end
  end
end
