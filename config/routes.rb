Rails.application.routes.draw do
  root 'products#index'

  resources :products, only: %i[index show] do
    get :search, on: :collection
  end
end
