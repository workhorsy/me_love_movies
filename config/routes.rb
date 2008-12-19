ActionController::Routing::Routes.draw do |map|
  map.resources :users, :member => { :set_user_type => :post,
									:set_review_rating => :post,
									:set_avatar_file => :post },
						:collection => { :login => :get, 
										:logout => :get, 
										:list => :get ,
										:forgot_password => :get,
										:set_is_email_activated => :get,
										:set_beta_activated => :get,
										:set_beta_delete => :get,
										:toggle_is_email_activated => :get,
										:beta => :get,
										:send_feedback => :get }
  map.resources :home, :collection => { :index => :get,
										:about => :get,
										:contact => :get,
										:privacy_policy => :get,
										:terms_of_service => :get,
										:why_sign_up => :get,
										:_box_office_love_edit => :get,
										:_box_office_love_update => :post,
										:_box_office_love_show => :get }
  map.resources :titles, :collection => { :search => :get }
  map.resources :title_ratings
  map.resources :title_reviews, :member => { :_list_by_title => :get }, 
								:collection => { :_add_title_comment => :get, 
												:_default_title_comment => :get,
												:_create_title_comment => :post}
  map.resources :admin, :collection => { :list_users => :get,
										:list_title_ratings => :get,
										:list_title_reviews => :get,
										:_user_admin_disable => :get,
										:_user_admin_enable => :get,
										:_user_admin_show => :get,
										:scrape_titles => :get,
										:_scrape_titles_show => :get,
										:_scrape_titles_edit => :get,
										:_scrape_titles_import => :post,
										:disable_user => :get,
										:enable_user => :get,
										:destroy_user => :get }
  map.resources :tags, :collection => {}

  map.root :controller => "home"

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
