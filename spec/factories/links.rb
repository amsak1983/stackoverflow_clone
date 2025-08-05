FactoryBot.define do
  factory :link do
    name { 'Test Link' }
    url { 'https://example.com' }
    association :linkable, factory: :question

    trait :gist do
      url { 'https://gist.github.com/user/123abc456def' }
    end

    trait :invalid_url do
      url { 'not-a-valid-url' }
    end
  end
end
