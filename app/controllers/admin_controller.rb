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

	# GET /admin/list
	# GET /admin/list.xml
	def list_users
		# FIXME: Have this require the user to be admin
		@users = User.find(:all)

		respond_to do |format|
			format.html # index.html.erb
			format.xml	{ render :xml => @users }
		end
	end
end
