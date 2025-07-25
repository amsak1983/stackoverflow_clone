FactoryBot.define do
  factory :answer do
    body { "Sample answer with detailed content" }
    association :question
    association :user
  end
end
