# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	def get_user_from_session
		return nil unless session[:user_id]

		user = User.find_by_id(session[:user_id])
		session[:user_id] = nil unless user
		return user
	end

	def get_months_hash
		i = 1
		%w{January February March April May June July August September October November December}.collect do |m|
			i += 1
			[m, i]
		end
	end
end
