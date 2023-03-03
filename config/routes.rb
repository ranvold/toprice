Rails.application.routes.draw do
  root 'products#index'

  resources :products, only: %i[index show] do
    get :query, on: :collection
  end
end
