class CreateNodes < ActiveRecord::Migration[6.0]
  def change
    create_table :nodes do |t|
      t.string  :address,          null: false
      t.integer :address_type,    null: false

      t.string :name
      t.string :symbol
      t.string :image_url
      t.string :external_url

      t.jsonb :holders,   default: {}
      t.jsonb :transfers, default: {}

      t.timestamps

      t.index [:address], unique: true
    end
  end
end
