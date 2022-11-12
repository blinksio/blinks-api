class RemoveTransfersAndHoldersFromNodes < ActiveRecord::Migration[6.0]
  def change
    remove_column :nodes, :holders
    remove_column :nodes, :transfers
  end
end
