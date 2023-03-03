class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.integer :price, null: false
      t.integer :discount, null: false
      t.integer :discount_price, null: false
      t.string :url, null: false
      t.date :expire, null: false
      t.string :amount
      t.references :company, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
    add_index :products, :url, unique: true
  end
end
