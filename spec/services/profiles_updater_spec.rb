RSpec.describe ProfilesUpdater do
  describe '#call' do
    let!(:profile) { create(:profile) }
    let(:new_attributes) { attributes_for(:profile) }
    let(:avatar) do
      Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'images', 'example.png'), 'image/png')
    end

    before do
      new_attributes.delete(:user)
      described_class.call(profile, new_attributes.merge(avatar: avatar))
      profile.reload
    end

    it 'updates profile first name' do
      expect(profile.first_name).to eq new_attributes[:first_name]
    end

    it 'updates profile last name' do
      expect(profile.last_name).to eq new_attributes[:last_name]
    end

    it 'updates profile avatar' do
      expect(profile.avatar.filename).to eq avatar.original_filename
    end
  end
end
