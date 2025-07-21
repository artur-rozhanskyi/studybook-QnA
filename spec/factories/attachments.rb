FactoryBot.define do
  factory :attachment do
    file { Rack::Test::UploadedFile.new(Rails.root.glob('spec/fixtures/images/example.png').first.to_s, 'image/png') }

    after :create do |blob|
      blob.update(file: 'example.png')
    end
  end
end
