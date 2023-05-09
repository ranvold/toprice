class Company < ApplicationRecord
  has_many :products, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true
  validates :endpoint, presence: true

  before_validation { name.upcase! }
end
