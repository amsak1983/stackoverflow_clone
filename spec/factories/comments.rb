FactoryBot.define do
  factory :comment do
    sequence(:body) { |n| "Comment body #{n} with some detailed content" }
    association :user
    association :commentable, factory: :question
  end
end
