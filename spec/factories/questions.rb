FactoryBot.define do
  factory :question do
    sequence(:title) { |n| "Question Title #{n}" }
    sequence(:body) { |n| "Question Body #{n} with detailed content" }
  end
end
