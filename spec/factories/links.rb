FactoryBot.define do
  factory :link do
    name { "Test link" }
    url { "https://example.com" }
    association :linkable, factory: :question
  end
end
