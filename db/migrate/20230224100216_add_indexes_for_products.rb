class AddIndexesForProducts < ActiveRecord::Migration[7.0]
  def change
    add_index :products, %i[expire discount]
    add_index :products, :name
  end
end
