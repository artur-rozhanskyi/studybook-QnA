FactoryBot.define do
  factory :answer do
    body { Faker::Lorem.sentence }
    question
    user

    factory :invalid_answer do
      body { nil }
    end
  end
end
