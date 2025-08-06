FactoryBot.define do
  factory :vote do
    association :user
    value { 1 }

    trait :for_question do
      association :votable, factory: :question
    end

    trait :for_answer do
      association :votable, factory: :answer
    end

    trait :upvote do
      value { 1 }
    end

    trait :downvote do
      value { -1 }
    end
  end
end
