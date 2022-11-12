class NftFetcherService
  attr_accessor :seed, :chain

  def initialize(chain = 'mainnet')
    @chain = chain
  end

  # starts with a seed address and fetches multiple NFT addresses
  def fetch_nft_addresses(seed, runs = 100)
    nfts = []

    seeds = [seed]

    while seeds.present? && runs > 0
      seed = seeds.pop

      puts "Fetching NFTs from #{seed}..."

      # fetching wallet addresses from seed nft
      addresses = fetch_wallet_addresses_from_nft(seed)

      # fetching nft addresses from wallet addresses (only fetching from a small sample)
      addresses.sample(25).each do |address|
        nfts += fetch_nft_addresses_from_wallet(address)
      end

      seeds += nfts.map { |nft| nft[:contract_address] }
      runs -= 1
    end

    # removing duplicates
    nfts.uniq
  end

  def fetch_nft_addresses_from_wallet(address)
    puts("Fetching NFTs from wallet #{address}...")

    # fetching all nft token transfers from wallet address
    nft_transfers = EtherscanService.new.nft_transfers_of_address(address)

    # getting all nft contract addresses from nft transfers
    nfts = nft_transfers.map do |tx|
      {
        contract_address: tx['contractAddress'],
        token_name: tx['tokenName'],
        token_symbol: tx['tokenSymbol'],
      }
    end

    # removing duplicates
    nfts.uniq
  end

  def fetch_wallet_addresses_from_nft(contract_address)
    nft_transfers = EtherscanService.new.nft_transfers_of_contract(contract_address)

    # getting all wallet addresses from nft transfers
    addresses = nft_transfers.map { |tx| tx['from'] } + nft_transfers.map { |tx| tx['to'] }

    # ignoring minting addresses
    addresses = addresses.reject { |address| address == '0x0000000000000000000000000000000000000000' }

    # removing duplicates
    addresses.uniq
  end
end
