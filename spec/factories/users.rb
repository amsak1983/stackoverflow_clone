FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    confirmed_at { Time.current }

    trait :oauth_user do
      provider { 'google_oauth2' }
      sequence(:uid) { |n| "oauth_uid_#{n}" }
    end

    trait :unconfirmed do
      confirmed_at { nil }
      
      after(:create) do |user|
        user.update_columns(confirmation_token: nil, confirmation_sent_at: nil) if user.oauth_user?
      end
    end

    trait :telegram_user do
      provider { 'telegram' }
      sequence(:uid) { |n| "telegram_#{n}" }
      email { "telegram_#{uid}@temp.local" }
      confirmed_at { nil }
    end

    trait :google_user do
      provider { 'google_oauth2' }
      sequence(:uid) { |n| "google_#{n}" }
      confirmed_at { Time.current }
    end
  end
end
