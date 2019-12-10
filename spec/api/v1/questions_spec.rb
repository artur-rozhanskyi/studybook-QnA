RSpec.describe 'Questions API' do
  describe '/index' do
    context 'when unauthorized' do
      it_behaves_like 'unauthorized_api' do
        let(:path) { '/api/v1/questions' }
      end
    end

    context 'when authorized' do
      context 'when authorized' do
        let!(:me) { create(:user) }
        let!(:questions) { create_list(:question, 5) }
        let(:access_token) { create(:access_token, resource_owner_id: me.id) }
        let(:question) { questions.first }

        before { get '/api/v1/questions/', params: { access_token: access_token.token, format: :json } }

        it 'returns 200 status' do
          expect(response.status).to eq 200
        end

        it 'returns all questions' do
          expect(response.body).to have_json_size(5)
        end

        %w[id title body].each do |attr|
          it "contains #{attr}" do
            expect(response.body).to be_json_eql(question.public_send(attr.to_sym).to_json).at_path("0/#{attr}")
          end
        end
      end
    end
  end

  describe '/show' do
    let!(:question) { create(:question, :with_comment, :with_file) }

    context 'when unauthorized' do
      it_behaves_like 'unauthorized_api' do
        let(:path) { "/api/v1/questions/#{question.id}" }
      end
    end

    context 'when authorized' do
      let!(:me) { create(:user) }
      let(:access_token) { create(:access_token, resource_owner_id: me.id) }

      before { get "/api/v1/questions/#{question.id}", params: { access_token: access_token.token, format: :json } }

      it 'returns 200 status' do
        expect(response.status).to eq 200
      end

      %w[id title body].each do |attr|
        it "contains #{attr}" do
          expect(response.body).to be_json_eql(question.public_send(attr.to_sym).to_json).at_path(attr.to_s)
        end
      end

      it 'contains comment' do
        expect(response.body).to have_json_size(1).at_path('comments')
      end

      %w[id body user_id].each do |attr|
        it "contains comment #{attr}" do
          expect(response.body).to be_json_eql(question.comments.first.public_send(attr.to_sym).to_json)
            .at_path("comments/0/#{attr}")
        end
      end

      it 'contains attachment' do
        expect(response.body).to have_json_size(1).at_path('attachments')
      end

      it 'contains attachment id' do
        expect(response.body).to be_json_eql(question.attachments.first.id.to_json).at_path('attachments/0/id')
      end

      it 'contains attachment filename' do
        expect(response.body).to be_json_eql(question.attachments.first.file.identifier.to_json)
          .at_path('attachments/0/filename')
      end

      it 'contains attachment url' do
        expect(response.body).to be_json_eql(question.attachments.first.file.url.to_json).at_path('attachments/0/url')
      end
    end
  end

  describe '/create' do
    let(:valid_attributes) { attributes_for(:question) }
    let(:invalid_attributes) { attributes_for(:question_invalid) }

    context 'when unauthorized' do
      it 'returns 401 status if there in no access token' do
        post '/api/v1/questions', params: { format: :json, question: valid_attributes }
        expect(response.status).to eq 401
      end

      it 'returns 401 status if access token is invalid' do
        post '/questions', params: { access_token: '1234', format: :json, question: valid_attributes }
        expect(response.status).to eq 401
      end
    end

    context 'when authorized' do
      let!(:me) { create(:user) }
      let(:access_token) { create(:access_token, resource_owner_id: me.id) }
      let(:question) { questions.first }

      context 'with valid attributes' do
        before do
          post '/api/v1/questions', params: { access_token: access_token.token,
                                              format: :json,
                                              question: valid_attributes }
        end

        it 'returns 201 status' do
          expect(response.status).to eq 201
        end

        it 'saves valid question' do
          expect do
            post '/api/v1/questions', params: { access_token: access_token.token,
                                                format: :json,
                                                question: valid_attributes }
          end.to change(Question, :count).by(1)
        end

        %w[title body].each do |attr|
          it "contains #{attr}" do
            expect(response.body).to be_json_eql(valid_attributes[attr.to_sym].to_json).at_path(attr.to_s)
          end
        end

        it 'contains id' do
          expect(response.body).to have_json_path('id')
        end
      end

      context 'with invalid attributes' do
        before do
          post '/api/v1/questions', params: { access_token: access_token.token,
                                              format: :json,
                                              question: invalid_attributes }
        end

        it 'returns 422 status' do
          expect(response.status).to eq 422
        end

        it 'does not save valid question' do
          expect do
            post '/api/v1/questions', params: { access_token: access_token.token,
                                                format: :json,
                                                question: invalid_attributes }
          end.not_to change(Question, :count)
        end

        it 'contains errors' do
          expect(response.body).to have_json_path('errors')
        end
      end
    end
  end
end
