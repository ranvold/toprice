class Product < ApplicationRecord
  belongs_to :category
  belongs_to :company

  validates :name, presence: true, uniqueness: { scope: :url }
  validates :price, presence: true
  validates :discount, presence: true
  validates :discount_price, presence: true
  validates :url, presence: true
  validates :expire, presence: true
end
