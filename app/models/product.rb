class Product < ApplicationRecord
  belongs_to :category
  belongs_to :company

  validates :name, presence: true, uniqueness: { scope: :url }
end
