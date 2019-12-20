RSpec.shared_examples_for 'user greeting' do
  let(:user_name) { UserPresenter.new(user).name }

  it 'renders user name' do
    expect(mail.body.encoded).to match(user_name)
  end
end
