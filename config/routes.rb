require 'sidekiq/web'

Rails.application.routes.draw do
  use_doorkeeper do
    # No need to register client application
    skip_controllers :applications, :authorized_applications
    # mount Sidekiq::Web => '/sidekiq'
  end
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks',
                                    registrations: 'users/registrations' }
  resources :questions, shallow: true do
    resources :answers do
      resources :comments
    end
    resources :comments
    post :subscribe, on: :member
    post :unsubscribe, on: :member
  end

  resources :users, only: :update do
    resource :profile, only: [:show, :update, :edit]
  end

  namespace :api do
    namespace :v1 do
      devise_for :users, controllers: {
        registrations: 'api/v1/users/registrations'
      }, skip: [:sessions, :password, :omniauth_callbacks]

      resources :users, only: [:index, :create] do
        get :me, on: :collection
      end

      resources :questions, only: [:index, :show, :create], shallow: true do
        resources :answers, only: [:index, :show, :create]
      end
    end
  end

  resource :search, only: :show

  root 'questions#index'

  mount ActionCable.server => '/cable'
end
