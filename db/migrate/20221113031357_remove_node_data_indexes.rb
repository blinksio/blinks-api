class RemoveNodeDataIndexes < ActiveRecord::Migration[6.0]
  def change
    remove_index :node_data, :transfers
    remove_index :node_data, :holders
  end
end
