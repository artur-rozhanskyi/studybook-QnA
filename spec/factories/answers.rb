FactoryBot.define do
  factory :answer do
    body { Faker::Lorem.sentence }
    question

    factory :invalid_answer do
      body { nil }
    end
  end
end
