RSpec.shared_examples_for 'attachments' do
  it 'contains attachment' do
    expect(response.body).to have_json_size(1).at_path('attachments')
  end

  it 'contains attachment id' do
    expect(response.body).to be_json_eql(resource.attachments.first.id.to_json).at_path('attachments/0/id')
  end

  it 'contains attachment filename' do
    expect(response.body).to be_json_eql(resource.attachments.first.file.identifier.to_json)
      .at_path('attachments/0/filename')
  end

  it 'contains attachment url' do
    expect(response.body).to be_json_eql(resource.attachments.first.file.url.to_json).at_path('attachments/0/url')
  end
end
