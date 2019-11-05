FactoryBot.define do
  factory :comment do
    body { Faker::Lorem.sentence }

    factory :invalid_comment do
      body { '' }
    end
  end
end
