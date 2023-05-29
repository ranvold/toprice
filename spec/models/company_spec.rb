require 'rails_helper'

RSpec.describe Company, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:products).dependent(:restrict_with_exception) }
  end

  describe 'validations' do
    subject { build(:company) }

    it { is_expected.to validate_presence_of(:endpoint) }
  end

  describe 'callbacks' do
    describe 'before_validation' do
      it 'converts the name to uppercase' do
        company = build(:company, name: 'example company')
        company.valid?

        expect(company.name).to eq('EXAMPLE COMPANY')
      end
    end
  end
end
