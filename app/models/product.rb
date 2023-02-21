class Product < ApplicationRecord
  belongs_to :category
  belongs_to :company
  belongs_to :promotion, optional: true

  validates :name, presence: true, uniqueness: { scope: :company_id }
end
