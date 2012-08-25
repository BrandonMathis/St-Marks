Stmarks::Application.routes.draw do
  mount Refinery::Core::Engine, :at => '/r'

  root to: 'high_voltage/pages#show', id: 'front'
end
