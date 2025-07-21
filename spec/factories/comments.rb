FactoryBot.define do
  factory :comment do
    body { Faker::Lorem.sentence }

    factory :invalid_comment do
      body { '' }
    end

    trait :for_question do
      commentable factory: [:question]
    end

    trait :for_answer do
      commentable factory: [:answer]
    end
  end
end
