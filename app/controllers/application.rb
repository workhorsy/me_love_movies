# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '455e48fedc601070a5a1eb98ddffca90'

	before_filter :login_return_users
	before_filter :check_for_disabled_user
	before_filter :check_beta_login_requirements

	def check_for_disabled_user
		# If the user has been marked as disabled, log them out, and take them to their profile
		if session[:user_id]
			user = User.find_by_id(session[:user_id])
			if user && user.disabled
				login_clear_sessions_and_cookies
				flash_notice "Your account has been disabled."
				redirect_to user_path(user)
			end

			# If the user is no longer in the database, clear their cookies and sessions
			if user == nil
				login_clear_sessions_and_cookies
			end
		end
	end

	def check_beta_login_requirements
		return if self.controller_name == "users"

		# If we are in beta, and the user is not logged in, take them to the beta page
		if Settings.is_beta && session[:user_id] == nil
			redirect_to :controller => 'users', :action => 'beta'
		end
	end

	def login_return_users
		if session[:user_id] == nil && cookies[:user_id] != nil:
			session[:user_id] = cookies[:user_id]
		end
	end

private

	def authorize_title_is_released
		# If that title is not released yet, show a message
		title = Title.find(params[:title_id])
		if title && title.release_date > DateTime.now
			flash_notice "That title is not released until #{title.release_date}"
			render :layout => 'default', :text => ""
		end
	end

	def authorize_admins_only
		user = User.find_by_id(session[:user_id])
		unless user && user.user_type == 'A'
			flash_notice "Only administrators can access this page."
			render :layout => 'default', :text => ""
		end
	end

	def authorize_moderators_only
		user = User.find_by_id(session[:user_id])
		unless user && user.user_type =~ /^(A|M)$/
			flash_notice "Only moderators and administrators can access this page."
			render :layout => 'default', :text => ""
		end
	end

	def authorize_users_only
		user = User.find_by_id(session[:user_id])
		unless user && user.user_type =~ /^(A|M|C|U)$/
			flash_notice "Only logged in users can access this page."
			render :layout => 'default', :text => ""
		end
	end

	def get_originating_user_id
		raise "The 'get_originating_user_id' method needs to be overwritten in the controller, before calling the 'authorize_originating_user_only' method."
	end

	def is_originating_user_or_admin
		user = User.find_by_id(session[:user_id])

		return !(user == nil || (get_originating_user_id != user.id && user.user_type != 'A'))
	end

	def authorize_originating_user_only
		unless is_originating_user_or_admin
			flash_notice "Only that user can access this page."
			render :layout => 'default', :text => ""
		end
	end

	def get_server_url(request)
		if ENV['RAILS_ENV'] == 'production'
			"http://melovemovies.com"
		else
			"http://" + request.env_table['HTTP_HOST']
		end
	end

	def valid_image_mime_types
		["image/gif", "image/jpg", "image/jpeg", "image/png"]
	end

	def flash_notice(value)
		cookies[:flash_notice] = value
		cookies[:flash_notice_is_shown] = "true"
	end

	def login_clear_sessions_and_cookies
		session[:user_id] = nil
		cookies[:user_name] = nil
		cookies[:user_greeting] = nil
		cookies[:user_type] = nil
		cookies[:user_id] = nil
	end

	def login_set_sessions_and_cookies(user, login_is_persistent)
		greetings = ['Howdy', 'Holla', 'Bonjour', 'Guten Tag', 'Aloha', 'Konnichi Wa']
		session[:user_id] = user.id

		# If the login is persistent, set the cookie expiration date 
		# for 30 days from now.
		expires = if login_is_persistent
			{:expires => 30.days.from_now}
		else
			{}
		end

		cookies[:user_name] = { :value => user.user_name }.merge(expires)
		cookies[:user_greeting] = { :value => greetings[rand(greetings.length)] }.merge(expires)
		cookies[:user_type] = { :value => user.user_type }.merge(expires)
		cookies[:user_id] = { :value => user.id.to_s }.merge(expires)
	end
end

