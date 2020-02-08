require 'capybara/rspec'
require 'selenium/webdriver'

Capybara.register_driver :chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w[no-sandbox headless disable-gpu disable-dev-shm-usage window-size=1920,1080] }
  )
  Capybara::Selenium::Driver.new(app, browser: :remote, desired_capabilities: capabilities, url: ENV['CHROME_HOSTNAME'])
end

Capybara.server_host = '0.0.0.0'
Capybara.server_port = Capybara::Server.new(Rails.application).send(:find_available_port, Capybara.server_host)

app_host = "http://#{`ip address show eth0 | grep inet | head -n1 | awk '{print $2}' | cut -d/ -f 1`.strip}"
Capybara.app_host = "#{app_host}:#{Capybara.server_port}"

Capybara.server = :puma, { Silent: true }

Capybara.javascript_driver = :chrome

Capybara.default_max_wait_time = 10
