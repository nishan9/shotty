Rails.application.routes.draw do

  get "up" => "rails/health#show", as: :rails_health_check

  post '/test', to: 'application#test'

  get '/directory', to: 'application#directory'
end
