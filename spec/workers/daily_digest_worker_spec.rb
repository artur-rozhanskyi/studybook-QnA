RSpec.describe DailyDigestWorker, type: :worker do
  describe 'testing worker' do
    it 'DailyDigestWorker jobs are enqueued in the default queue' do
      described_class.perform_async
      expect(described_class.queue).to eq 'default'
    end

    it 'goes into the jobs array for testing environment' do
      expect { described_class.perform_async }.to change(described_class.jobs, :size).by(1)
      described_class.new.perform
    end
  end
end
