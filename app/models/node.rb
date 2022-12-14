class Node < ApplicationRecord
  enum address_type: [:erc721, :erc20, :wallet]

  validates :address, presence: true, uniqueness: true
  validates :address_type, presence: true

  has_one :node_data, dependent: :destroy

  MIN_SCORE = 10

  def update_nft_transfers
    # disabling logging due to very verbosy output
    current_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    # trying blokness first, fallback to etherscan if the response is empty
    transfers = BloknessService.new.nft_transfers_of_contract(address)
    transfers = EtherscanService.new.nft_transfers_of_contract(address) if transfers.blank?

    node_data = NodeData.find_or_create_by(node: self)
    node_data.transfers = transfers
    node_data.save
    ActiveRecord::Base.logger = current_logger

    # triggering a transfer_addresses cache refresh
    transfer_addresses(refresh: true)
  end

  def transfer_addresses(refresh: false)
    return @transfer_addresses if @transfer_addresses.present?

    # checking if result is cached
    @transfer_addresses ||= Rails.cache.read("transfer_addresses:#{address}")

    return @transfer_addresses if !@transfer_addresses.nil? && !refresh

    return [] if node_data.blank?

    @transfer_addresses = Rails.cache.fetch("transfer_addresses:#{address}", force: refresh) do
      transfers = node_data.transfers.to_a

      transfers.map { |tx| tx['from'] } + transfers.map { |tx| tx['to'] }

      # getting all wallet addresses from nft transfers
      addresses = transfers.map { |tx| tx['from'] } + transfers.map { |tx| tx['to'] }

      # ignoring minting addresses
      addresses = addresses.reject { |address| address == '0x0000000000000000000000000000000000000000' }

      # minimizing addresses and removing duplicates
      addresses.map { |address| address[2..8] }.uniq
    end
  end

  def score_vs_node(other_node)
    # calculating score based on number of common addresses
    (transfer_addresses & other_node.transfer_addresses).count
  end

  def related_node_scores(nodes: nil, refresh: false)
    Rails.cache.fetch("node_scores:#{address}", force: refresh) do
      # fetching all nodes with node data
      nodes ||= Node.where(id: NodeData.pluck(:node_id))

      # excluding self node
      nodes = nodes.to_a.reject { |node| node.id == id }

      # excluding spam nodes
      nodes = nodes.to_a.reject { |node| node.spam }

      # calculating scores for all nodes
      scores = nodes.map { |n| [n.id, score_vs_node(n)] }.to_h

      # selecting top nodes
      scores.select { |_, score| score > MIN_SCORE }
    end
  end

  def related_node_ids
    # filtering top 10 nodes with a score > 10
    related_node_scores
      .select { |_, score| score > MIN_SCORE }
      .sort_by { |_, score| -score }
      .map { |id, _| id }
      .first(10)
  end

  def related_nodes
    Node.where(id: related_node_ids).where(spam: false)
  end

  def update_erc721_image_url
    return unless erc721?

    # trying blokness first, fallback to etherscan if the response is empty
    collection_details = BloknessService.new.collection_details(address)

    return if collection_details.blank? || collection_details['icon'].blank?

    self.image_url = collection_details['icon']
    save
  end

  # TODO: move to serializer?
  def serialize
    {
      id: id,
      address: address,
      name: name,
      symbol: symbol,
      image_url: image_url,
      meta: meta
    }
  end
end
