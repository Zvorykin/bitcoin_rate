# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'ui#index'

  namespace 'api' do
    resources :bitcoin_rates, only: [:index]
  end
end
