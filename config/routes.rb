Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  resources :questions, shallow: true do
    resources :answers do
      resources :comments
    end
    resources :comments
  end

  resources :users, only: :update do
    resource :profile, only: [:show, :update, :edit]
  end

  namespace :api do
    namespace :v1 do
      resources :users, only: :index do
        get :me, on: :collection
      end
    end
  end

  root 'questions#index'

  mount ActionCable.server => '/cable'
end
