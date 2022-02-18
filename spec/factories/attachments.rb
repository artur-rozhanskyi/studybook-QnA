FactoryBot.define do
  factory :attachment do
    file { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'images', 'example.png'), 'image/png') }

    after :create do |b|
      b.update(file: 'example.png')
    end
  end
end
