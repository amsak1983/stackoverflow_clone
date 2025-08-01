FactoryBot.define do
  factory :link do
    name { "Тестовая ссылка" }
    url { "https://example.com" }
    association :linkable, factory: :question
  end
end
