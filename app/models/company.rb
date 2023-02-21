class Company < ApplicationRecord
  has_many :products, dependent: :destroy
  has_many :promotions, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
