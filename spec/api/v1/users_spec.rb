# frozen_string_literal: true

RSpec.describe 'User API' do
  describe 'GET /me' do
    context 'when unauthorized' do
      it_behaves_like 'unauthorized_api' do
        let(:path) { '/api/v1/users/me' }
      end
    end

    context 'when authorized' do
      let(:me) { create(:user) }
      let(:access_token) { create(:access_token, resource_owner_id: me.id) }

      before { get '/api/v1/users/me', params: { access_token: access_token.token, format: :json } }

      it 'returns 200 status' do
        expect(response.status).to eq 200
      end

      %w[id first_name last_name].each do |attr|
        it "contains #{attr}" do
          expect(response.body).to be_json_eql(me.profile.public_send(attr.to_sym).to_json).at_path("profile/#{attr}")
        end
      end

      %w[email role].each do |attr|
        it "contains #{attr}" do
          expect(response.body).to be_json_eql(me.public_send(attr.to_sym).to_json).at_path(attr)
        end
      end
    end
  end

  describe 'GET /index' do
    context 'when unauthorized' do
      it_behaves_like 'unauthorized_api' do
        let(:path) { '/api/v1/users/' }
      end
    end

    context 'when authorized' do
      let!(:me) { create(:user) }
      let!(:users) { create_list(:user, 2) }
      let(:access_token) { create(:access_token, resource_owner_id: me.id) }
      let(:user) { users.first }

      before { get '/api/v1/users/', params: { access_token: access_token.token, format: :json } }

      it 'returns 200 status' do
        expect(response.status).to eq 200
      end

      it 'returns all profiles except me' do
        expect(response.body).to have_json_size(2)
      end

      %w[id first_name last_name].each do |attr|
        it "contains #{attr}" do
          expect(response.body).to be_json_eql(user.profile.public_send(attr.to_sym).to_json)
            .at_path("0/profile/#{attr}")
        end
      end

      %w[email role].each do |attr|
        it "contains #{attr}" do
          expect(response.body).to be_json_eql(user.public_send(attr.to_sym).to_json).at_path("0/#{attr}")
        end
      end

      it 'does not include current user' do
        expect(response.body).not_to include_json(me.to_json)
      end
    end
  end
end
