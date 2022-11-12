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
end
