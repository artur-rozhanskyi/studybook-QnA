FactoryBot.define do
  factory :question do
    user
    title { Faker::Lorem.question }
    body  { Faker::Lorem.paragraph }

    trait :with_file do
      before(:create) do |question|
        create(:attachment, attachmentable: question)
      end
    end

    trait :with_comment do
      before(:create) do |question|
        create(:comment, commentable: question, user: question.user)
      end
    end

    factory :question_invalid do
      title { nil }
      body  { nil }
    end
  end
end
