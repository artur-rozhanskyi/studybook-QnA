RSpec.configure do |config|
  config.before do |example|
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
  end

  config.before(:suite) do
    DatabaseCleaner.clean_with(:deletion)
  end

  config.before do |example|
    DatabaseCleaner.start
    ThinkingSphinx::Configuration.instance.settings['real_time_callbacks'] = (example.metadata[:sphinx] == true)
  end

  config.use_transactional_fixtures = false

  config.before(:each, sphinx: true) do
    ThinkingSphinx::Test.init
    ThinkingSphinx::Test.start index: false
  end

  config.after(:each, sphinx: true) do
    ThinkingSphinx::Test.stop
    ThinkingSphinx::Test.clear
  end

  config.append_after do
    DatabaseCleaner.clean
  end
end
