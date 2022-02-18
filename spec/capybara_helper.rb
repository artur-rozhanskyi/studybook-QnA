require 'capybara/rspec'
require 'selenium/webdriver'

Capybara.server = :puma, { Silent: true }
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new app, browser: :chrome,  
    capabilities: Selenium::WebDriver::Chrome::Options.new(args: %w[headless disable-gpu])
end
  
Capybara.javascript_driver = :chrome
Capybara.default_max_wait_time = 10
