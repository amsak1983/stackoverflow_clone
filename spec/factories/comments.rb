FactoryBot.define do
  factory :comment do
    body { "MyText" }
    commentable { nil }
    user { nil }
  end
end
