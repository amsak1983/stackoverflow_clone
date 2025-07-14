FactoryBot.define do
  factory :answer do
    body { "You can use the Devise gem which is compatible with Rails 8. It provides a complete authentication solution." }
    association :question
  end
end
