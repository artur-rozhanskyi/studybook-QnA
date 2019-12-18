RSpec.shared_examples 'nested comments controller' do
  let(:valid_attributes) { attributes_for(:comment) }
  let(:commenter) { "#{commentable.class.to_s.downcase}_id" }
  let(:comment) { create(commentable.class.to_s.downcase, :with_comment, user: comment_user).comments.first }

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'saves valid comment' do
        expect do
          post :create, params: { comment: attributes_for(:comment), "#{commenter}": commentable },
                        format: :json,
                        session: valid_session
        end
          .to change(Comment, :count).by(1)
      end

      it 'publish created comment to comment chanel' do
        expect(ActionCable.server).to receive(:broadcast)
        post :create, params: { comment: valid_attributes, "#{commenter}": commentable },
                      format: :json,
                      session: valid_session
      end
    end

    context 'with invalid attributes' do
      it 'does not save invalid comments' do
        expect do
          post :create, params: { comment: attributes_for(:invalid_comment), "#{commenter}": commentable },
                        format: :json,
                        session: valid_session
        end
          .not_to change(Comment, :count)
      end

      it 'not to render template create' do
        post :create, params: { "#{commenter}": commentable, comment: valid_attributes },
                      format: :json,
                      session: valid_session
        expect(response).not_to render_template :create
      end
    end
  end

  describe 'PATCH #update' do
    let(:new_attributes) { { body: Faker::Lorem.sentence } }

    describe 'belongs to current user' do
      context 'with valid attributes' do
        before do
          patch :update, params: { id: comment, comment: new_attributes }, format: :json
        end

        it 'assigns a requested comment to @comment' do
          expect(assigns(:comment)).to eq comment
        end

        it 'changes question comment' do
          comment.reload
          expect(comment.body).to eq new_attributes[:body]
        end

        it 'publish updated comment to comment chanel' do
          expect(ActionCable.server).to receive(:broadcast)
          patch :update, params: { id: comment, comment: new_attributes }, format: :json
        end
      end

      context 'with invalid attributes' do
        before do
          patch :update, params: { id: comment, comment: new_attributes }, format: :json
        end

        it 'do not changes comment' do
          reloaded_comment = comment.reload
          expect(reloaded_comment).to eq comment
        end
      end
    end

    describe 'not belongs to current user' do
      it 'not changes comment body' do
        sign_in_user(create(:user))
        patch :update, params: { id: comment, comment: new_attributes }, format: :json
        comment.reload
        expect(comment.body).not_to eq new_attributes[:body]
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      sign_in_user(comment.user)
    end

    context 'when delete questions comment ' do
      describe 'belongs to current user' do
        it 'deletes comment' do
          expect do
            delete :destroy, params: { id: comment }, format: :json
          end
            .to change(Comment, :count).by(-1)
        end

        it 'publish deleted comment to comment chanel' do
          expect(ActionCable.server).to receive(:broadcast)
          delete :destroy, params: { id: comment }, format: :json
        end
      end

      describe 'not belongs to current user' do
        it 'has not change comment count' do
          sign_in_user(create(:user))
          expect do
            delete :destroy, params: { id: comment }, format: :json
          end
            .not_to change(Comment, :count)
        end
      end
    end
  end
end
