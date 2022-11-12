class Node < ApplicationRecord
  enum address_type: [:erc721, :erc20, :wallet]

  validates :address, presence: true, uniqueness: true
  validates :address_type, presence: true

  has_one :node_data, dependent: :destroy

  def update_nft_transfers
    # disabling logging due to very verbosy output
    current_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    self.transfers = EtherscanService.new.nft_transfers_of_contract(address)
    self.save
    ActiveRecord::Base.logger = current_logger
  end
end
