class Company < ApplicationRecord
  has_many :products, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :endpoint, presence: true

  before_validation { name.upcase! }
end
