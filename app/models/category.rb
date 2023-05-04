class Category < ApplicationRecord
  has_many :products, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :keywords, presence: true

  def keywords_by_semicolons
    keywords&.gsub('\\b', '')&.split('|')&.map { |word| "#{word};" }&.join
  end

  def keywords_by_semicolons=(val)
    self.keywords = val.split(';').map { |word| "\\b#{word}\\b" }.join('|')
  end
end
