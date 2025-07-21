RSpec.shared_examples_for 'unauthorized_api' do |method|
  it 'returns 401 status if there in no access token' do
    send method, path, format: :json
    expect(last_response).to have_http_status :unauthorized
  end

  it 'returns 401 status if access token is invalid' do
    send method, path, access_token: '1234', format: :json
    expect(last_response).to have_http_status :unauthorized
  end
end
