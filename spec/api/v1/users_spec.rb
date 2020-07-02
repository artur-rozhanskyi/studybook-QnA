RSpec.describe 'User API', type: :api do
  let(:me) { create(:user) }

  describe 'GET #me' do
    context 'when unauthorized' do
      it_behaves_like 'unauthorized_api', :get do
        let(:path) { '/api/v1/users/me.json' }
      end
    end

    context 'when authorized' do
      before do
        sign_in_as_a_valid_user(me)
        get '/api/v1/users/me.json'
      end

      it 'returns 200 status' do
        expect(last_response.status).to eq 200
      end

      %w[id first_name last_name].each do |attr|
        it "contains #{attr}" do
          expect(last_response.body)
            .to be_json_eql(me.profile.public_send(attr.to_sym).to_json).at_path("profile/#{attr}")
        end
      end

      %w[email role].each do |attr|
        it "contains #{attr}" do
          expect(last_response.body).to be_json_eql(me.public_send(attr.to_sym).to_json).at_path(attr)
        end
      end
    end
  end

  describe 'GET #index' do
    context 'when unauthorized' do
      it_behaves_like 'unauthorized_api', :get do
        let(:path) { '/api/v1/users.json' }
      end
    end

    context 'when authorized' do
      let!(:users) { create_list(:user, 2) }
      let(:user) { users.first }

      before do
        sign_in_as_a_valid_user(me)
        get '/api/v1/users.json'
      end

      it 'returns 200 status' do
        expect(last_response.status).to eq 200
      end

      it 'returns all profiles except me' do
        expect(last_response.body).to have_json_size(2)
      end

      %w[id first_name last_name].each do |attr|
        it "contains #{attr}" do
          expect(last_response.body).to be_json_eql(user.profile.public_send(attr.to_sym).to_json)
            .at_path("0/profile/#{attr}")
        end
      end

      %w[email role].each do |attr|
        it "contains #{attr}" do
          expect(last_response.body).to be_json_eql(user.public_send(attr.to_sym).to_json).at_path("0/#{attr}")
        end
      end

      it 'does not include current user' do
        expect(last_response.body).not_to include_json(me.to_json)
      end
    end
  end
end
