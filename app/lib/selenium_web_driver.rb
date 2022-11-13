class SeleniumWebDriver
  attr_accessor :driver

  def initialize(headless: true)
    opts = { args: ['disable-dev-shm-usage', 'no-sandbox', 'window-size=1440,900'] }
    opts[:args] << 'headless' if headless

    Selenium::WebDriver::Chrome.path = ENV['GOOGLE_CHROME_SHIM'] if ENV['GOOGLE_CHROME_SHIM'].present?
    @driver = Selenium::WebDriver.for(:chrome, options: Selenium::WebDriver::Chrome::Options.new(opts))

    @driver.manage.timeouts.implicit_wait = 30
  end
end
