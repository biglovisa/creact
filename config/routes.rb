Rails.application.routes.draw do
  root to: 'site#index'

  namespace :api do
    namespace :v1 do
      resources :skills, only: [:index, :create, :destroy, :update]
    end
  end
end
