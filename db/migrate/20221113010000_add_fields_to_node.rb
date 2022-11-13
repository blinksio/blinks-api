class AddFieldsToNode < ActiveRecord::Migration[6.0]
  def change
    add_column :nodes, :spam, :boolean, default: false
    add_column :nodes, :meta, :jsonb, default: {}
    remove_column :nodes, :external_url
  end
end
