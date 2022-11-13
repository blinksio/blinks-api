class OpenseaService
  attr_accessor :driver

  def initialize
    @driver = SeleniumWebDriver.new(headless: false).driver
  end

  def get_collection_data(contract_address)
    uri = "https://api.opensea.io/api/v1/asset_contract/#{contract_address}?format=json"

    driver.navigate.to(uri)

    response = driver.find_elements(:xpath, '//pre').last.text

    JSON.parse(response)
  end
end
