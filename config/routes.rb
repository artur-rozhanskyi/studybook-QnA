Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  resources :questions, shallow: true do
    resources :answers do
      resources :comments
    end
    resources :comments
  end

  root 'questions#index'

  mount ActionCable.server => '/cable'
end
