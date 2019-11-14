# frozen_string_literal: true

Rails.application.routes.draw do
  resources :accounts do
  end
  resources :users

  scope 'operations' do
    get '/check_balance/:number' => 'accounts#check_balance'
    post '/transfer' => 'accounts#transfer'
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
