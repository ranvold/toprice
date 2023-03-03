class ProductsController < ApplicationController
  include Pagy::Backend

  before_action :set_filter, only: %i[index query]

  def index
    @pagy, @products = pagy(Product.current)
  end

  def show
    @product = Product.find(params[:id])
  end

  def query
    @products = if params[:companies].present? && params[:categories].present?
                  Product.current.where(company: params[:companies].split(',').map(&:to_i), category: params[:categories].split(',').map(&:to_i))
                elsif params[:categories].present?
                  Product.current.where(category: params[:categories].split(',').map(&:to_i))
                elsif params[:companies].present?
                  Product.current.where(company: params[:companies].split(',').map(&:to_i))
                else
                  Product.current
                end

    @products = Product.current.where('name ILIKE ? and id in (?)', "%#{params[:name]}%", @products.ids) if params[:name].present?

    @pagy, @products = pagy(@products)

    respond_to do |format|
      format.turbo_stream
      format.html { render :index }
    end
  end

  private

  def set_filter
    @companies = Company.all
    @categories = Category.all
  end
end
