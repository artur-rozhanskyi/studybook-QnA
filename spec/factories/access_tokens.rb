FactoryBot.define do
  factory :access_token, class: 'Doorkeeper::AccessToken' do
    application { association :oauth_application }
    resource_owner_id { create(:user).id }
  end
end
