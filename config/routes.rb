Rails.application.routes.draw do
  root 'products#index'

  namespace :admin_panel do
    devise_for :admins, controllers: { sessions: 'admin_panel/admins/sessions',
                                       registrations: 'admin_panel/admins/registrations',
                                       passwords: 'admin_panel/admins/passwords',
                                       unlocks: 'admin_panel/admins/unlocks' }

    resources :categories
  end

  resources :products, only: %i[index show] do
    get :search, on: :collection
  end
end
