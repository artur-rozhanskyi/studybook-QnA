require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module StudybookQna
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Don't generate system test files.
    config.generators.system_tests = nil
    config.generators.javascript_engine = :js
    config.active_job.queue_adapter = :sidekiq
    config.eager_load_paths << Rails.root.join('lib')
  end
end
