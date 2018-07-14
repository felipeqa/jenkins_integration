require 'rspec'
require 'cucumber'
require 'selenium/webdriver'
require 'capybara/dsl'
require 'httparty'

World Capybara::DSL
BROWSER = ENV['BROWSER']

Capybara.default_driver = :selenium_chrome

if BROWSER.eql?('remote')
  Capybara.register_driver :selenium_chrome do |app|
    Capybara::Selenium::Driver.new(app,
      :browser => :remote,
      :desired_capabilities => :chrome,
      :url => "http://selenium-hub:4444/wd/hub"
    )
  end
else
  Capybara.register_driver :selenium_chrome do |app|
    options = {
      :js_errors => false,
      :timeout => 360,
      :debug => false,
      :inspector => false,
    }
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
  end
end
