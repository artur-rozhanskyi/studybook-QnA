RSpec.shared_examples_for 'comments' do
  %w[id body].each do |attr|
    it "contains #{attr}" do
      expect(last_response.body).to be_json_eql(resource.public_send(attr.to_sym).to_json).at_path(attr.to_s)
    end
  end

  it 'contains comment' do
    expect(last_response.body).to have_json_size(1).at_path('comments')
  end

  %w[id body user_id].each do |attr|
    it "contains comment #{attr}" do
      expect(last_response.body).to be_json_eql(resource.comments.first.public_send(attr.to_sym).to_json)
        .at_path("comments/0/#{attr}")
    end
  end
end
