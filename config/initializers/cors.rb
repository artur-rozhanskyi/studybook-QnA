ORIGINS = [ENV.fetch('CLIENT_ORIGIN') { '' }].freeze

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*ORIGINS)
    resource '*',
             headers: :any,
             methods: [:get, :post, :put, :patch, :delete, :options, :head],
             credentials: true
  end
end
