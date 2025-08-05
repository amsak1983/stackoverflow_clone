FactoryBot.define do
  factory :reward do
    title { "Amazing Reward" }
    association :question
    association :user
    recipient { nil }

    after(:build) do |reward|
      reward.image.attach(
        io: StringIO.new('fake image data'),
        filename: 'reward_image.jpg',
        content_type: 'image/jpeg'
      )
    end

    trait :awarded do
      association :recipient, factory: :user
    end

    trait :with_png_image do
      after(:build) do |reward|
        reward.image.attach(
          io: StringIO.new('fake png data'),
          filename: 'reward_image.png',
          content_type: 'image/png'
        )
      end
    end
  end
end
