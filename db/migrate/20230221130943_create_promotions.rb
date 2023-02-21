class CreatePromotions < ActiveRecord::Migration[7.0]
  def change
    create_table :promotions do |t|
      t.string :name, null: false
      t.date :expiration, null: false
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
    add_index :promotions, %i[name company_id], unique: true
  end
end
