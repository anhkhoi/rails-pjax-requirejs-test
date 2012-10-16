PjaxRequirejsTest::Application.routes.draw do
  scope "(:mobile)", defaults: { mobile: nil }, mobile: /(mobile)?/ do
    resources :items do
      resources :guides, except: :index
    end
    root to: "items#index"
  end
end
