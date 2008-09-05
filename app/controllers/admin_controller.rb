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
		@users = User.paginate :page => params[:page], :per_page => User.per_page

		respond_to do |format|
			format.html
			format.xml	{ render :xml => @users }
		end
	end	

	# GET /admin/list_title_reviews
	# GET /admin/list_title_reviews.xml
	def list_title_reviews
		@title_reviews = TitleReview.paginate :page => params[:page], :per_page => TitleReview.per_page

		respond_to do |format|
			format.html
			format.xml	{ render :xml => @title_reviews }
		end
	end

	# GET /admin/list_title_ratings
	# GET /admin/list_title_ratings.xml
	def list_title_ratings
		@title_ratings = TitleRating.paginate :page => params[:page], :per_page => TitleRating.per_page

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

