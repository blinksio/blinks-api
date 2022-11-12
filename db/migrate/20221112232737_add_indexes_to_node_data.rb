class AddIndexesToNodeData < ActiveRecord::Migration[6.0]
  def change
    add_index :node_data, :transfers, using: :gin
    add_index :node_data, :holders, using: :gin
  end
end
