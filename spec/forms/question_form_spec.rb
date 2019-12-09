RSpec.describe QuestionForm do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:question) }
  let(:question_form) { described_class.new }
  let(:invalid_attributes) { attributes_for(:question_invalid) }

  it 'not to be valid' do
    expect(question_form).not_to be_valid
  end

  describe '#submit' do
    let(:question) { create(:question) }
    let(:question_form_with_question) { described_class.new(question) }

    context 'when create question' do
      context 'with valid attributes' do
        it 'to be valid' do
          expect(question_form.submit(valid_attributes.merge(user: user))).to be_truthy
        end

        it 'saves valid question' do
          expect { question_form.submit(valid_attributes.merge(user: user)) }.to change(Question, :count).by(1)
        end
      end

      context 'with invalid attributes' do
        it 'to be valid' do
          expect(question_form.submit(invalid_attributes.merge(user: user))).to be_falsey
        end

        it 'not saves invalid question' do
          expect { question_form.submit(invalid_attributes.merge(user: user)) }.not_to change(Question, :count)
        end
      end
    end

    context 'when update question' do
      context 'when belong to user' do
        context 'with valid attributes' do
          before do
            question_form_with_question.submit(valid_attributes.merge(user: question.user))
            question.reload
          end

          it 'to be valid' do
            expect(question_form_with_question.submit(valid_attributes.merge(user: question.user))).to be_truthy
          end

          it 'updates question title' do
            expect(question.title).to eq valid_attributes[:title]
          end

          it 'updates question body' do
            expect(question.body).to eq valid_attributes[:body]
          end
        end

        context 'with invalid attributes' do
          it 'not to be valid' do
            expect(question_form_with_question.submit(invalid_attributes.merge(user: user))).to be_falsey
          end

          it 'not to saves invalid question' do
            expect { question_form.submit(invalid_attributes.merge(user: user)) }.not_to change(Question, :count)
          end
        end
      end

      context 'when not belong to user' do
        let(:another_user) { create(:user) }

        context 'with valid attributes' do
          it 'not update question' do
            old_question = question
            question_form_with_question.submit(valid_attributes.merge(user: another_user))
            question.reload
            expect(question).to eq old_question
          end
        end

        context 'with invalid attributes' do
          it 'not to be valid' do
            expect(question_form_with_question.submit(invalid_attributes.merge(user: user))).to be_falsey
          end

          it 'not to saves invalid question' do
            expect { question_form.submit(invalid_attributes.merge(user: user)) }.not_to change(Question, :count)
          end
        end
      end
    end
  end
end
