FactoryBot.define do
  factory :question do
    user
    title { Faker::Lorem.question }
    body  { Faker::Lorem.paragraph }

    trait :with_file do
      before(:create) do |question|
        question.attachments << create(:attachment, attachmentable: question)
      end
    end

    factory :question_invalid do
      title { nil }
      body  { nil }
    end
  end
end
