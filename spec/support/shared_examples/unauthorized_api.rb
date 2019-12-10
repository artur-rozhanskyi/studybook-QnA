RSpec.shared_examples_for 'unauthorized_api' do |path|
  it 'returns 401 status if there in no access token' do
    get path, params: { format: :json }
    expect(response.status).to eq 401
  end

  it 'returns 401 status if access token is invalid' do
    get path, params: { access_token: '1234', format: :json }
    expect(response.status).to eq 401
  end
end
