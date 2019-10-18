require 'capybara/rspec'
require 'selenium/webdriver'

Capybara.server = :puma, { Silent: true }
Capybara.javascript_driver = :selenium_chrome_headless
