module Search
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    delegate :logger, to: :Rails

    def client
      Client.instance
    end
  end
end
