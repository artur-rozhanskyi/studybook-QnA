FactoryBot.define do
  factory :answer do
    body { Faker::Lorem.sentence }
    question
    user

    trait :with_file do
      before(:create) do |answer|
        create(:attachment, attachmentable: answer)
      end
    end

    trait :with_comment do
      before(:create) do |answer|
        create(:comment, commentable: answer, user: answer.user)
      end
    end

    factory :invalid_answer do
      body { nil }
    end
  end
end
