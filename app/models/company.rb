class Company < ApplicationRecord
  has_many :products, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  FORA_URL = 'https://fora.ua/promotions'.freeze
end
