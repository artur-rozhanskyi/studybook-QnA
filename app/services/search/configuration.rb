module Search
  class Configuration
    attr_reader :url, :username, :password, :index_prefix, :backend,
                :request_timeout, :open_timeout, :read_timeout

    def initialize(options = {})
      assign_options(options)
    end

    def enabled?
      opensearch? && url.present?
    end

    def opensearch?
      backend == 'opensearch'
    end

    def client_options
      {}.merge(host_options).merge(auth_options).merge(timeout_options).merge(transport_options)
    end

    private

    def option(options, key, env_key, default = nil)
      options.key?(key) ? options[key] : ENV.fetch(env_key, default)
    end

    def default_backend
      url.present? ? 'opensearch' : 'database'
    end

    def cast_timeout(value)
      value.presence&.to_i
    end

    def assign_options(options)
      normalized = normalized_options(options)

      @url, @username, @password, @index_prefix, @backend,
        @request_timeout, @open_timeout, @read_timeout = normalized.values_at(
          :url, :username, :password, :index_prefix, :backend,
          :request_timeout, :open_timeout, :read_timeout
        )
    end

    def host_options
      { hosts: [url] }
    end

    def auth_options
      options = {}
      options[:user] = username if username.present?
      options[:password] = password if password.present?
      options
    end

    def timeout_options
      timeout = request_timeout.presence || read_timeout.presence
      timeout.present? ? { request_timeout: timeout } : {}
    end

    def transport_options
      return {} if open_timeout.blank?

      {
        transport_options: {
          request: {
            open_timeout: open_timeout
          }
        }
      }
    end

    def normalized_options(options)
      {
        url: option(options, :url, 'OPENSEARCH_URL').presence,
        username: option(options, :username, 'OPENSEARCH_USERNAME').presence,
        password: option(options, :password, 'OPENSEARCH_PASSWORD').presence,
        index_prefix: option(options, :index_prefix, 'OPENSEARCH_INDEX_PREFIX', 'studybook-qna'),
        backend: option(options, :backend, 'SEARCH_BACKEND').presence || default_backend,
        request_timeout: cast_timeout(option(options, :request_timeout, 'OPENSEARCH_TIMEOUT')),
        open_timeout: cast_timeout(option(options, :open_timeout, 'OPENSEARCH_OPEN_TIMEOUT')),
        read_timeout: cast_timeout(option(options, :read_timeout, 'OPENSEARCH_READ_TIMEOUT'))
      }
    end
  end
end
