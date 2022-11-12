class EtherscanService
  attr_accessor :chain

  def initialize(chain = 'mainnet')
    @chain = chain
  end

  def token_supply(contract_address)
    uri = etherscan_url + "/api?module=stats&action=tokensupply&contractaddress=#{contract_address}&apikey=#{api_key}"

    request_etherscan(uri).to_i
  end

  def contract_txs(contract_address)
    uri = etherscan_url + "/api?module=account&action=txlist&address=#{contract_address}&sort=desc&apikey=#{api_key}"

    request_etherscan(uri)
  end

  def nft_transfers_of_contract(contract_address)
    uri = etherscan_url + "/api?module=account&action=tokennfttx&contractaddress=#{contract_address}&sort=desc&apikey=#{api_key}"

    request_etherscan(uri)
  end

  def nft_transfers_of_address(address)
    uri = etherscan_url + "/api?module=account&action=tokennfttx&address=#{address}&sort=desc&apikey=#{api_key}"

    request_etherscan(uri)
  end

  def token_transfers(contract_address)
    uri = etherscan_url + "/api?module=account&action=tokentx&contractaddress=#{contract_address}&sort=desc&apikey=#{api_key}"

    request_etherscan(uri)
  end

  def token_owners(contract_address)
    # NOTE: only works for 10k transfers maximum
    owners = {}

    token_transfers(contract_address).each do |tx|
      token_id = tx['tokenID'].to_i
      # order is descending, only considering first tx
      next if owners[token_id].present?

      owners[token_id] = tx['to']
    end

    owners.sort.to_h
  end

  def latest_mints(contract_address)
    contract_txs(contract_address).select do |tx|
      tx['value'].to_i > 0 && tx['value'].to_i % 70000000000000000 == 0 && tx['isError'] == '0'
    end
  end

  def logs(contract_address)
    uri = etherscan_url + "/api?module=logs&action=getLogs&address=#{contract_address}&apikey=#{api_key}"

    request_etherscan(uri)
  end

  def latest_block_number(contract_address)
    contract_txs(contract_address).first['blockNumber'].to_i
  end

  def address_balances(addresses)
    balances = []

    # etherscan allows chunks of 20 addresses each
    addresses.each_slice(20) do |address_book|
      uri = etherscan_url + "/api?module=account&action=balancemulti&address=#{address_book.join(',')}&tag=latest&apikey=#{api_key}"

      response = HTTP.get(uri)

      unless response.status.success?
        raise "Etherscan #{response.status} :: #{response.body.to_s}"
      end

      balances += JSON.parse(response.body.to_s)['result'].map do |balance|
        {
          address: balance['account'],
          balance: balance['balance'].to_f / 10**18
        }
      end
    end

    balances
  end

  private

  def request_etherscan(uri)
    response = HTTP.get(uri)

    unless response.status.success?
      raise "Etherscan #{response.status} :: #{response.body.to_s}"
    end

    result = JSON.parse(response.body.to_s)['result']

    if result.is_a?(String)
      raise "Etherscan :: #{result}"
    end

    result
  end

  def etherscan_url
    @_etherscan_url ||=
      case chain
      when 'mainnet'
        'https://api.etherscan.io'
      when 'goerli'
        'https://api-goerly.etherscan.io'
      when 'polygon'
        'https://api.polygonscan.com'
      else
        raise "EtherscanService :: Chain #{chain} unknown"
      end
  end

  def api_key
    @_api_key ||=
      case chain
      when 'mainnet', 'rinkeby'
        Rails.application.config_for(:etherscan).api_key
      when 'polygon'
        Rails.application.config_for(:etherscan).polygon_api_key
      else
        raise "EtherscanService :: Chain #{chain} unknown"
      end
  end
end
