class Category < ApplicationRecord
  has_many :products, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :keywords, presence: true

  def keywords=(value)
    super(value.split(';').map { |word| "\\b#{word}\\b" }.join('|'))
  end
end
