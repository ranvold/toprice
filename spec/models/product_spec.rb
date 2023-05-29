require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:category) }
    it { is_expected.to belong_to(:company) }
    it { is_expected.to have_one_attached(:image) }
  end

  describe 'validations' do
    subject { build(:product) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:price) }
    it { is_expected.to validate_presence_of(:discount) }
    it { is_expected.to validate_presence_of(:discount_price) }
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_uniqueness_of(:url) }
    it { is_expected.to validate_presence_of(:expire_on) }
  end

  describe 'scopes' do
    describe '.current' do
      it 'returns products with an expiration date greater than or equal to the current date' do
        product1 = create(:product, expire_on: Date.current)
        product2 = create(:product, expire_on: Date.tomorrow)
        create(:product, expire_on: Date.yesterday)

        expect(described_class.current).to contain_exactly(product1, product2)
      end
    end

    describe '.order_by_discount' do
      it 'orders products by discount in descending order' do
        product1 = create(:product, discount: 50)
        product2 = create(:product, discount: 30)
        product3 = create(:product, discount: 70)

        expect(described_class.order_by_discount).to eq([product3, product1, product2])
      end
    end

    describe '.by_company' do
      it 'returns products belonging to specified company ids' do
        company1 = create(:company)
        company2 = create(:company)
        product1 = create(:product, company: company1)
        create(:product, company: company2)
        product3 = create(:product, company: company1)

        expect(described_class.by_company([company1.id])).to contain_exactly(product1, product3)
      end
    end

    describe '.by_category' do
      it 'returns products belonging to specified category ids' do
        category1 = create(:category)
        category2 = create(:category)
        product1 = create(:product, category: category1)
        create(:product, category: category2)
        product3 = create(:product, category: category1)

        expect(described_class.by_category([category1.id])).to contain_exactly(product1, product3)
      end
    end

    describe '.by_name' do
      it 'returns products matching the specified name' do
        product1 = create(:product, name: 'Apple iPhone')
        create(:product, name: 'Samsung Galaxy')
        product3 = create(:product, name: 'iPhone X')

        expect(described_class.by_name('iphone')).to contain_exactly(product1, product3)
      end
    end
  end

  describe 'methods' do
    describe '.categorize' do
      let!(:company) { create(:company) }
      let!(:category1) { create(:category, name: 'Електроніка', keywords_by_semicolons: 'iphone;macbook;') }
      let!(:category2) { create(:category, name: 'Одяг', keywords_by_semicolons: 't-shirt;') }
      let!(:category3) { create(:category, name: 'Інше', keywords_by_semicolons: 'інше!;') }

      it 'categorizes new products based on keywords' do
        new_products = [
          {
            name: 'iPhone XS',
            price_in_uah: 10_000.00,
            discount: 15,
            discount_price_in_uah: 8500.00,
            url: 'https://example.com/product1',
            expire_on: Date.tomorrow,
            company:,
            image: fixture_file_upload('spec/fixtures/images/product.png', 'image/png')
          },
          {
            name: 'MacBook Pro 16 2022',
            price_in_uah: 125_000.00,
            discount: 10,
            discount_price_in_uah: 112_500.00,
            url: 'https://example.com/product2',
            expire_on: Date.tomorrow,
            company:,
            image: fixture_file_upload('spec/fixtures/images/product.png', 'image/png')
          },
          {
            name: 'White t-shirt',
            price_in_uah: 400.00,
            discount: 25,
            discount_price_in_uah: 300.00,
            url: 'https://example.com/product2',
            expire_on: Date.tomorrow,
            company:,
            image: fixture_file_upload('spec/fixtures/images/product.png', 'image/png')
          },
          {
            name: 'Shoes',
            price_in_uah: 4_000.00,
            discount: 20,
            discount_price_in_uah: 3200.00,
            url: 'https://example.com/product1',
            expire_on: Date.tomorrow,
            company:,
            image: fixture_file_upload('spec/fixtures/images/product.png', 'image/png')
          }
        ]

        categorized_products = described_class.categorize(new_products)

        expect(categorized_products.map do |product|
          { name: product[:name], category: product[:category] }
        end).to contain_exactly(
          { name: 'iPhone XS', category: category1 },
          { name: 'MacBook Pro 16 2022', category: category1 },
          { name: 'White t-shirt', category: category2 },
          { name: 'Shoes', category: category3 }
        )
      end
    end

    describe '.update_existing_products' do
      it 'updates existing products with parsed data' do
        existing_product1 = create(:product, url: 'https://example.com/product1')
        existing_product2 = create(:product, url: 'https://example.com/product2')
        parsed_existing_products = [
          { url: 'https://example.com/product1', price_in_uah: 20.00, discount: 20, discount_price_in_uah: 16.00,
            expire_on: Date.tomorrow },
          { url: 'https://example.com/product2', price_in_uah: 15.00, discount: 10, discount_price_in_uah: 13.50, expire_on: Date.current }
        ]

        described_class.update_existing_products(parsed_existing_products)

        existing_product1.reload
        existing_product2.reload

        expect(existing_product1).to have_attributes(
          price_in_uah: 20.00,
          discount: 20,
          discount_price_in_uah: 16.00,
          expire_on: Date.tomorrow
        )
        expect(existing_product2).to have_attributes(
          price_in_uah: 15.00,
          discount: 10,
          discount_price_in_uah: 13.50,
          expire_on: Date.current
        )
      end
    end

    describe '.add_new_products' do
      it 'creates new products and attaches images' do
        category = create(:category, keywords_by_semicolons: 'fresh;')
        company = create(:company)
        parsed_products = [
          {
            name: 'Fresh Orange',
            price_in_uah: 10.00,
            discount: 15,
            discount_price_in_uah: 8.50,
            url: 'https://example.com/product1',
            expire_on: Date.tomorrow,
            company:,
            category:,
            image: fixture_file_upload('spec/fixtures/images/product.png', 'image/png')
          },
          {
            name: 'Fresh',
            price_in_uah: 15.00,
            discount: 20,
            discount_price_in_uah: 12.00,
            url: 'https://example.com/product2',
            expire_on: Date.current,
            company:,
            category:,
            image: fixture_file_upload('spec/fixtures/images/product.png', 'image/png')
          }
        ]

        expect do
          described_class.add_new_products(parsed_products)
        end.to change(described_class, :count).by(2)
      end
    end

    describe '#price_in_uah' do
      it 'returns the price in UAH' do
        product = build(:product, price: 10_000)

        expect(product.price_in_uah).to eq(100.0)
      end
    end

    describe '#discount_price_in_uah' do
      it 'returns the discount price in UAH' do
        product = build(:product, discount_price: 8000)

        expect(product.discount_price_in_uah).to eq(80.0)
      end
    end

    describe '#price_in_uah=' do
      it 'sets the price based on the value in UAH' do
        product = build(:product, price_in_uah: 150.0)

        expect(product.price).to eq(15_000)
      end
    end

    describe '#discount_price_in_uah=' do
      it 'sets the discount price based on the value in UAH' do
        product = build(:product, discount_price_in_uah: 120.0)

        expect(product.discount_price).to eq(12_000)
      end
    end
  end
end
