class ChangeColumnExpiration < ActiveRecord::Migration[7.0]
  def change
    rename_column :products, :expiration, :expire_on
  end
end
