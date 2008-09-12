class AdminController < ApplicationController
	layout 'default'
	before_filter :authorize_admins_only

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
end

