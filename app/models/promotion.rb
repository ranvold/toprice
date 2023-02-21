class Promotion < ApplicationRecord
  belongs_to :company

  has_many :products, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :company_id }
  validates :expiration, presence: true
end
