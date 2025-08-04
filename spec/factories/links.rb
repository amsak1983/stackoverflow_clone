FactoryBot.define do
  factory :link do
    name { "Test link" }
    url { "https://example.com" }
    association :linkable, factory: :question
    
    trait :gist do
      name { "My gist" }
      url { "https://gist.github.com/test/123456" }
    end
  end
end
