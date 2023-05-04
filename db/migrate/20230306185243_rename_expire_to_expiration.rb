class RenameExpireToExpiration < ActiveRecord::Migration[7.0]
  def change
    rename_column :products, :expire, :expiration
  end
end
