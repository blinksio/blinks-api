class NftTransfersWorker
  include Sidekiq::Worker

  def perform(node_id)
    node = Node.find_by(id: node_id)
    return if node.blank?

    raise "Node is not an ERC721 contract" if node.address_type != "erc721"

    node.update_nft_transfers
  end
end
