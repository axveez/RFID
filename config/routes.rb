Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root "main#index"
  get "main/index" => "main#index"
  get "/login" => "main#login"
  post "/login" => "main#login"


  get "/logout" => "main#logout"

  get "spb1/index" => "spb1#index"
  post "spb1/stop_ws" => "spb1#stop_ws"
  get "/spb1" => "spb1#index"
  post "spb1/cru" => "spb1#cru"

  get "spb2/index" => "spb2#index"
  post "spb2/stop_ws" => "spb2#stop_ws"
  get "/spb2" => "spb2#index"
  post "spb2/cru" => "spb2#cru"

  get "spb5/index" => "spb5#index"
  post "spb5/stop_ws" => "spb5#stop_ws"
  get "/spb5" => "spb5#index"
  post "spb5/cru" => "spb5#cru"

  get "/setting" => "main#setting"

  post "/" => "main#index"
end
