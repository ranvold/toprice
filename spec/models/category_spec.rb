require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:products).dependent(:restrict_with_exception) }
  end

  describe 'validations' do
    subject { build(:category, keywords_by_semicolons: 'keyword;') }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:keywords) }
  end

  describe 'scopes' do
    describe '.order_by_id' do
      it 'orders categories by id' do
        category1 = create(:category, id: 2, keywords_by_semicolons: 'keyword2;')
        category2 = create(:category, id: 1, keywords_by_semicolons: 'keyword1;')

        expect(described_class.order_by_id).to eq([category2, category1])
      end
    end
  end

  describe 'methods' do
    describe '#keywords_by_semicolons' do
      it 'returns keywords separated by semicolons' do
        category = build(:category, keywords: '\bkeyword1\b|\bkeyword2\b|\bkeyword3\b')

        expect(category.keywords_by_semicolons).to eq('keyword1;keyword2;keyword3;')
      end
    end

    describe '#keywords_by_semicolons=' do
      it 'sets keywords from semicolon-separated values' do
        category = build(:category, keywords_by_semicolons: 'keyword1;keyword2;keyword3')

        expect(category.keywords).to eq('\bkeyword1\b|\bkeyword2\b|\bkeyword3\b')
      end
    end
  end
end
