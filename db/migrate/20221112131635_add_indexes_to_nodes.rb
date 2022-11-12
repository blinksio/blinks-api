class AddIndexesToNodes < ActiveRecord::Migration[6.0]
  def change
    add_index :nodes, :transfers, using: :gin
    add_index :nodes, :holders, using: :gin
  end
end
