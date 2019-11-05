RSpec.shared_examples 'nested comments controller' do
  let(:valid_attributes) { attributes_for(:comment) }
  let(:commenter) { "#{commentable.class.to_s.downcase}_id" }
  let(:comment) { create(:question, :with_comment, user: comment_user).comments.first }

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'saves valid comment' do
        expect do
          post :create, params: { comment: attributes_for(:comment), "#{commenter}": commentable, user: comment_user },
                        format: :json,
                        session: valid_session
        end
          .to change(Comment, :count).by(1)
      end

      it 'render template create' do
        post :create, params: { "#{commenter}": commentable, comment: valid_attributes },
                      format: :json,
                      session: valid_session
        expect(response.body).to include valid_attributes[:body]
      end
    end

    context 'with invalid attributes' do
      it 'does not save invalid comments' do
        expect do
          post :create, params: { "#{commenter}": commentable, comment: attributes_for(:invalid_comment) },
                        format: :json,
                        session: valid_session
        end
          .not_to change(Comment, :count)
      end

      it 'render template create' do
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

        it 'assigns a requested question to @question' do
          expect(assigns(:comment)).to eq comment
        end

        it 'changes question body' do
          comment.reload
          expect(comment.body).to eq new_attributes[:body]
        end
      end

      context 'with invalid attributes' do
        before do
          patch :update, params: { id: comment, comment: new_attributes }, format: :json
        end

        it 'do not changes question' do
          reloaded_comment = comment.reload
          expect(reloaded_comment).to eq comment
        end
      end
    end

    describe 'not belongs to current user' do
      it 'not changes question body' do
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
        it 'deletes question' do
          expect do
            delete :destroy, params: { id: comment }, format: :js
          end
            .to change(Comment, :count).by(-1)
        end
      end

      describe 'not belongs to current user' do
        it 'has not change answer count' do
          sign_in_user(create(:user))
          expect do
            delete :destroy, params: { id: comment }, format: :js
          end
            .not_to change(Comment, :count)
        end
      end
    end
  end
end
