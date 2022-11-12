class Node < ApplicationRecord
  enum address_type: [:erc721, :erc20, :wallet]

  validates :address, presence: true, uniqueness: true
  validates :address_type, presence: true

  has_one :node_data, dependent: :destroy

  def update_nft_transfers
    # disabling logging due to very verbosy output
    current_logger = ActiveRecord::Base.logger
    # ActiveRecord::Base.logger = nil
    transfers = EtherscanService.new.nft_transfers_of_contract(address)
    node_data = NodeData.find_or_create_by(node: self)
    node_data.transfers = transfers
    node_data.save
    ActiveRecord::Base.logger = current_logger
  end

  def transfer_addresses
    # checking if result is cached
    return Rails.cache.read("transfer_addresses:#{address}") if Rails.cache.exist?("transfer_addresses:#{address}")

    return [] if node_data.blank? || node_data.transfers.blank?

    Rails.cache.fetch("transfer_addresses:#{address}", expires_in: 1.day) do
      node_data.transfers.map { |tx| tx['from'] } + node_data.transfers.map { |tx| tx['to'] }

      # getting all wallet addresses from nft transfers
      addresses = node_data.transfers.map { |tx| tx['from'] } + node_data.transfers.map { |tx| tx['to'] }

      # ignoring minting addresses
      addresses = addresses.reject { |address| address == '0x0000000000000000000000000000000000000000' }

      # removing duplicates
      addresses.uniq
    end
  end

  def score_vs_node(other_node)
    # calculating score based on number of common addresses
    (transfer_addresses & other_node.transfer_addresses).count
  end

  def related_node_scores(refresh: false)
    Rails.cache.fetch("node_scores:#{address}", expires_in: 1.day, force: refresh) do
      # fetching all nodes with node data
      nodes = Node.where(id: NodeData.pluck(:node_id)).where.not(id: id)

      # calculating scores for all nodes
      scores = nodes.map { |n| [n.id, score_vs_node(n)] }.to_h
    end
  end

  def related_node_ids
    # filtering top 10 nodes with a score > 10
    related_node_scores
      .select { |_, score| score > 10 }
      .sort_by { |_, score| -score }
      .map { |id, _| id }
      .first(10)
  end

  def related_nodes
    Node.where(id: related_node_ids)
  end

  # TODO: move to serializer?
  def serialize
    {
      id: id,
      address: address,
      name: name,
      symbol: symbol,
      image_url: image_url,
      meta: {}
    }
  end
end
