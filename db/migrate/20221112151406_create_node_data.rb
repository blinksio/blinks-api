class CreateNodeData < ActiveRecord::Migration[6.0]
  def change
    create_table :node_data do |t|
      t.references :node, null: false, foreign_key: true, unique: true

      t.jsonb :holders,   default: []
      t.jsonb :transfers, default: []

      t.timestamps
    end
  end
end
