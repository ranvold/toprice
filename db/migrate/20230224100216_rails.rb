class Rails < ActiveRecord::Migration[7.0]
  def change
    add_index :products, %i[expire discount]
  end
end
