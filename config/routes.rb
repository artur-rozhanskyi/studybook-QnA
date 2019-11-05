Rails.application.routes.draw do
  devise_for :users
  resources :questions do
    resources :answers
    resources :comments, shallow: true
  end

  root 'questions#index'
end
