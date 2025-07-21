FactoryBot.define do
  factory :oauth_application, class: 'Doorkeeper::Application' do
    sequence(:name)  { |n| "App#{n}" }
    sequence(:uid)   { |n| "uid#{n}" }
    sequence(:secret) { |n| "secret#{n}" }
    redirect_uri { 'urn:ietf:wg:oauth:2.0:oob' }
  end
end
