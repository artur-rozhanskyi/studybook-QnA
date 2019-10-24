FactoryBot.define do
  factory :answer do
    body { Faker::Lorem.sentence }
    question
    user

    trait :with_file do
      before(:create) do |answer|
        answer.attachments << create(:attachment, attachmentable: answer)
      end
    end

    factory :invalid_answer do
      body { nil }
    end
  end
end
