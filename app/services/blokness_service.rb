class BloknessService
  attr_accessor :chain

  def initialize(chain = 'mainnet')
    @chain = chain
  end

  def collection_details(contract_address)
    uri = blokness_url + "/collections/#{contract_address}"

    res = request_blokness(uri)

    res['data']
  end

  def nft_transfers_of_contract(contract_address)
    uri = blokness_url + "/transactions?collection=#{contract_address}&limit=100"

    res = request_blokness(uri)

    data = format_nft_transfers(res['data'])

    # iterating through cursor
    while res['next']
      uri = blokness_url + res['next']

      res = request_blokness(uri)

      data += format_nft_transfers(res['data'])
    end

    data
  end

  private

  def format_nft_transfers(transfers)
    transfers.map do |transfer|
      transfer.merge({ "from" => transfer['address_from'], "to" => transfer['address_to'] })
    end
  end

  def request_blokness(uri)
    response = HTTP
      .headers("x-api-key" => api_key)
      .get(uri)

    unless response.status.success?
      raise "Blokness #{response.status} :: #{response.body.to_s}"
    end

    result = JSON.parse(response.body.to_s)

    if result.is_a?(String)
      raise "Blokness :: #{result}"
    end

    result
  end

  def blokness_url
    @_blokness_url ||=
      case chain
      when 'mainnet'
        'http://api.blokness.io'
      else
        raise "BloknessService :: Chain #{chain} unknown"
      end
  end

  def api_key
    @_api_key ||= Rails.application.config_for(:blokness).api_key
  end
end
