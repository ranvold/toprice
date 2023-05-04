module AdminPanel
  class CategoriesController < AdminPanelController
    before_action :set_category, only: %i[show edit update destroy]

    def index
      @categories = Category.all
    end

    def show; end

    def new
      @category = Category.new
    end

    def create
      @category = Category.new(category_params)

      if @category.save
        redirect_to admin_panel_category_path(@category)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @category.update(category_params)
        redirect_to admin_panel_category_path(@category)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @category.destroy

      redirect_to root_path, status: :see_other
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :keywords_by_semicolons)
    end
  end
end
