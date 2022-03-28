RSpec.shared_examples_for 'action cable broadcast' do |serializer, subject_name, action|
  let(:fake_serializer) { object_double(serializer, as_json: '') }

  it "publishes new answer to #{subject_name} chanel" do
    allow(serializer).to receive(:new).and_return(fake_serializer)
    expect(ActionCable.server).to receive(:broadcast)
      .with(channel,
            { 'action' => action, subject_name => fake_serializer }.as_json)
    request_for
  end
end
