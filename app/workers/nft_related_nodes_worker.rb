class NftRelatedNodesWorker
  include Sidekiq::Worker

  def perform(node_id)
    node = Node.find_by(id: node_id)
    return if node.blank?

    raise "Node is not an ERC721 contract" if node.address_type != "erc721"

    node.related_node_scores(refresh: true)
  end
end
