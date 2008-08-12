# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	def get_user_from_session
		return nil unless session[:user_id]

		user = User.find_by_id(session[:user_id])
		session[:user_id] = nil unless user
		return user
	end

	def authorize_originating_user_only
		if params[:id].to_i != session[:user_id]
			render :layout => 'default', :text => "<p id=\"flash_notice\">You don't have permission to access this page.</p>"
		end
	end
end
