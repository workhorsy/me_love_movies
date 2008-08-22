class AdminController < ApplicationController
	layout 'default'

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
end

