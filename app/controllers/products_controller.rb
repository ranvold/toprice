class ProductsController < ApplicationController
  def index
    @companies = Company.all
    @categories = Category.all
    @products = Product.current
  end

  def show
    @product = Product.find(params[:id])
  end
end
