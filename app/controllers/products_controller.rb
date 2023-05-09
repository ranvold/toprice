class ProductsController < ApplicationController
  include Pagy::Backend

  before_action :set_filter, only: %i[index search]

  def index
    @pagy, @products = pagy(Product.current.order_by_discount)
  end

  def show
    @product = Product.find(params[:id])
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  def search
    companies = JSON.parse(params[:companies]) if params[:companies].present?
    categories = JSON.parse(params[:categories]) if params[:categories].present?
    name = JSON.parse(params[:name]) if params[:name].present?

    @products = Product.current

    @products = @products.by_company(companies) if companies.present?
    @products = @products.by_category(categories) if categories.present?
    @products = @products.by_name(name) if name.present?
    @products = @products.order_by_discount if @products.present?

    @pagy, @products = pagy(@products)

    respond_to do |format|
      format.html { render :index }
      format.turbo_stream
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize

  private

  def set_filter
    @companies = Company.all
    @categories = Category.order_by_id
  end
end
