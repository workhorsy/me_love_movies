class AdminController < ApplicationController
	layout 'default'
	before_filter :authorize_admin_only

	# GET /admin
	# GET /admin.xml
	def index
		respond_to do |format|
			format.html # index.html.erb
			format.xml	{ render :xml => '' }
		end
	end

	# GET /admin/list_users
	# GET /admin/list_users.xml
	def list_users
		# FIXME: Have this require the user to be admin
		@users = User.find(:all)

		respond_to do |format|
			format.html
			format.xml	{ render :xml => @users }
		end
	end	

	# GET /admin/list_title_reviews
	# GET /admin/list_title_reviews.xml
	def list_title_reviews
		# FIXME: Have this require the user to be admin
		@title_reviews = TitleReview.find(:all)

		respond_to do |format|
			format.html
			format.xml	{ render :xml => @title_reviews }
		end
	end

	# GET /admin/list_title_ratings
	# GET /admin/list_title_ratings.xml
	def list_title_ratings
		# FIXME: Have this require the user to be admin
		@title_ratings = TitleRating.find(:all)

		respond_to do |format|
			format.html
			format.xml	{ render :xml => @title_ratings }
		end
	end

	private

	def authorize_admin_only
		@user = User.find_by_id(session[:user_id])
		unless @user && @user.user_type == UserType::NAMES_ABBREVIATIONS.select { |k, v| v == 'A' }.first.last
			render :layout => 'default', :text => "<p id=\"flash_notice\">You don't have permission to access this page.</p>"
		end
	end
end

