PjaxRequirejsTest::Application.routes.draw do
  resources :items do
    resources :guides, except: :index
  end
  root to: "items#index"
end
