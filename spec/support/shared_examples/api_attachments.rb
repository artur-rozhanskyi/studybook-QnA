RSpec.shared_examples_for 'api_attachments' do |object_string|
  let(:params) { attributes_for(object_string) }
  let(:file_param) do
    {
      attachments_attributes: {
        '0' => { file: Base64.encode64(File.read(Rails.root.join('spec', 'fixtures', 'images', 'example.png'))) }
      }
    }
  end

  describe "POST #{object_string}" do
    before { sign_in_as_a_valid_user(user) }

    it 'saves attachment' do
      expect do
        post post_path, object_string => params.merge(file_param), format: :json
      end.to change(Attachment, :count).by(1)
    end
  end

  describe "PATCH #{object_string}" do
    let!(:created_object) { create(object_string, :with_file, user: user) }
    let(:delete_param) do
      { attachments_attributes: { '0' => { id: created_object.attachments.first.id, _destroy: '1' } } }
    end
    let(:delete_attachments_params) { params.merge(delete_param) }
    let(:new_attachments_params) { params.merge(file_param) }

    before { sign_in_as_a_valid_user(user) }

    it 'deletes attachment' do
      expect do
        patch "#{patch_path}/#{created_object.id}", object_string => delete_attachments_params, format: :json
      end.to change { created_object.attachments.count }.by(-1)
    end

    it 'adds new attachment' do
      expect do
        patch "#{patch_path}/#{created_object.id}", object_string => new_attachments_params, format: :json
      end.to change { created_object.attachments.count }.by(1)
    end
  end
end
