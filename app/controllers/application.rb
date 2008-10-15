# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '455e48fedc601070a5a1eb98ddffca90'

	before_filter :check_beta_login_requirements

	def check_beta_login_requirements
		return if self.controller_name == "users"

		# If we are in beta, and the user is not logged in, take them to the beta page
		if Settings.is_beta && session[:user_id] == nil
			redirect_to :controller => 'users', :action => 'beta'
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

	def authorize_originating_user_only
		user = User.find_by_id(session[:user_id])

		if user == nil || (get_originating_user_id != user.id && user.user_type != 'A')
			render :layout => 'default', :text => "<p id=\"flash_notice\">Only that user can access this page.</p>"
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
	end
end

