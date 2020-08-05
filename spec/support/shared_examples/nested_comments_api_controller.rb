RSpec.shared_examples 'nested comments api controller' do
  let(:valid_attributes) { attributes_for(:comment) }
  let(:invalid_attributes) { attributes_for(:invalid_comment) }
  let!(:comment) { create(commentable.class.to_s.downcase, :with_comment, user: comment_user).comments.first }
  let(:commenter) { "#{commentable.class.to_s.downcase}_id" }

  describe 'POST /api/v1/comments' do
    context 'when unauthorized' do
      it_behaves_like 'unauthorized_api', :post do
        let(:path) { '/api/v1/comments' }
      end
    end

    context 'when authorized' do
      before { sign_in_as_a_valid_user(comment_user) }

      context 'with valid attributes' do
        it 'saves valid comment' do
          expect do
            post '/api/v1/comments', comment: valid_attributes, "#{commenter}": commentable.id, format: :json
          end
            .to change(commentable.comments, :count).by(1)
        end

        it 'publishes created comment to comment channel' do
          expect(ActionCable.server).to receive(:broadcast)
            .with('question/comments',
                  hash_including('comment' => hash_including(valid_attributes.as_json),
                                 'action' => 'create'))
          post '/api/v1/comments', comment: valid_attributes, "#{commenter}": commentable.id, format: :json
        end
      end

      context 'with invalid attributes' do
        it 'does not save invalid comments' do
          expect do
            post '/api/v1/comments', comment: invalid_attributes, "#{commenter}": commentable.id, format: :json
          end
            .not_to change(Comment, :count)
        end
      end
    end
  end

  describe 'PATCH /api/v1/comments/:id' do
    let(:new_attributes) { { body: Faker::Lorem.sentence } }

    context 'when unauthorized' do
      it_behaves_like 'unauthorized_api', :patch do
        let(:path) { "/api/v1/comments/#{comment.id}" }
      end
    end

    context 'when authorized' do
      describe 'belongs to current user' do
        before { sign_in_as_a_valid_user(comment_user) }

        context 'with valid attributes' do
          before do
            patch "/api/v1/comments/#{comment.id}", comment: new_attributes, format: :json
          end

          it 'changes comment' do
            comment.reload
            expect(comment.body).to eq new_attributes[:body]
          end

          it 'publishes updated comment to comment channel' do
            expect(ActionCable.server).to receive(:broadcast)
              .with('question/comments', hash_including(
                                           'comment' => hash_including(new_attributes.as_json),
                                           'action' => 'update'
                                         ))
            patch "/api/v1/comments/#{comment.id}", comment: new_attributes, format: :json
          end
        end

        context 'with invalid attributes' do
          it 'does not changes comment' do
            expect do
              patch "/api/v1/comments/#{comment.id}", comment: invalid_attributes, format: :json
            end.not_to change(comment, :body)
          end
        end
      end

      describe 'not belongs to current user' do
        it 'changes comment body' do
          sign_in_as_a_valid_user(create(:user))
          expect do
            patch "/api/v1/comments/#{comment.id}", comment: valid_attributes, format: :json
          end.not_to change(comment, :body)
        end
      end
    end
  end

  describe 'DELETE /api/v1/comments/:id' do
    context 'when unauthorized' do
      it_behaves_like 'unauthorized_api', :delete do
        let(:path) { "/api/v1/comments/#{comment.id}" }
      end
    end

    context 'when authorized' do
      context 'when belongs to current user' do
        before do
          sign_in_as_a_valid_user(comment_user)
        end

        it 'deletes comment' do
          expect do
            delete "/api/v1/comments/#{comment.id}", format: :json
          end
            .to change(Comment, :count).by(-1)
        end

        it 'publishes deleted comment to comment channel' do
          expect(ActionCable.server).to receive(:broadcast).with('question/comments',
                                                                 { comment: comment, action: 'destroy' }.as_json)
          delete "/api/v1/comments/#{comment.id}", format: :json
        end
      end

      context 'when does not belongs to current user' do
        it 'does not change comment count' do
          sign_in_as_a_valid_user(create(:user))
          expect do
            delete "/api/v1/comments/#{comment.id}", format: :json
          end
            .not_to change(Comment, :count)
        end
      end
    end
  end
end
