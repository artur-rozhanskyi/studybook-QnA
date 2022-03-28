FactoryBot.define do
  factory :profile do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    user { association :user, profile: @instance }
    avatar { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'images', 'example.png'), 'image/png') }
  end
end
