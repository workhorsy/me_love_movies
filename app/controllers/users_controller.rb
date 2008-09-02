class UsersController < ApplicationController
	layout 'default'
	before_filter :authorize_originating_user_only, :only => ['edit', 'update', 'destroy', 'set_review_rating']

	# GET /users
	# GET /users.xml
	def index
		redirect_to :controller => 'home', :action => 'index'
	end

	# GET /users/1
	# GET /users/1.xml
	def show
		@user = User.find(params[:id])
		@title_reviews = TitleReview.find(:all, :conditions => ["user_id=?", @user.id])
		# FIXME: Optimize this to be a single query!
		@title_reviews = @title_reviews.sort {|x,y| Title.find_by_id(y.title_id).name <=> Title.find_by_id(x.title_id).name }.reverse

		@title_ratings = TitleRating.find(:all, :conditions => ["user_id=?", @user.id])
		@title_ratings = @title_ratings.sort {|x,y| Title.find_by_id(y.title_id).name <=> Title.find_by_id(x.title_id).name }.reverse

		respond_to do |format|
			format.html # show.html.erb
			format.xml	{ render :xml => @user }
		end
	end

	# GET /users/new
	# GET /users/new.xml
	def new
		@user = User.new

		respond_to do |format|
			format.html # new.html.erb
			format.xml	{ render :xml => @user }
		end
	end

	# POST /users
	# POST /users.xml
	def create
		@user = User.new(params[:user])
		@user.user_type = UserType::NAMES_ABBREVIATIONS.select { |k, v| v == 'U' }.first.last

		respond_to do |format|
			if @user.save
				flash[:notice] = 'User was successfully created.'
				format.html { redirect_to(@user) }
				format.xml	{ render :xml => @user, :status => :created, :location => @user }
			else
				format.html { render :action => "new" }
				format.xml	{ render :xml => @user.errors, :status => :unprocessable_entity }
			end
		end
	end

	# GET /users/1/edit
	def edit
		@user = User.find(params[:id])
	end

	# PUT /users/1
	# PUT /users/1.xml
	def update
		@user = User.find(params[:id])

		respond_to do |format|
			if @user.update_attributes(params[:user])
				flash[:notice] = 'User was successfully updated.'
				format.html { redirect_to(@user) }
				format.xml	{ head :ok }
			else
				format.html { render :action => "edit" }
				format.xml	{ render :xml => @user.errors, :status => :unprocessable_entity }
			end
		end
	end

=begin
	# DELETE /users/1
	# DELETE /users/1.xml
	def destroy
		@user = User.find(params[:id])
		@user.destroy

		respond_to do |format|
			format.html { redirect_to(users_url) }
			format.xml	{ head :ok }
		end
	end
=end

	# GET /users/login
	# GET /users/login.xml
	def login
		session[:user_id] = nil
		return unless request.post?

		user = User.authenticate(params[:user_name], params[:password])
		if user
			session[:user_id] = user.id
			flash[:notice] = "Successfully loged in."
			redirect_to(:controller => 'home', :action => :index)
		else
			flash[:notice] = "Login failed. Try again."
		end
	end

	# GET /users/set_user_type
	# GET /users/set_user_type.xml
	def set_user_type
		# Make sure the user making this request is an admin
		unless User.find(session[:user_id]).user_type == 'A'
			render :text => "You are not an Administrator"
			return
		end

		# Make sure the user is not locking themselves out
		if session[:user_id] == params[:id].to_i
			render :partial => "admin/cant_lock_yourself_out", :locals => { :user_id => params[:id].to_i }
			return
		end

		# Change the user's permissions
		@user, name = nil, nil
		begin
			@user = User.find(params[:id])
			pair = UserType::NAMES_ABBREVIATIONS.select { |k, v| k == params[:user_type] }.first
			name = pair.first
			@user.user_type = pair.last
		rescue
		end
		if @user.save
			render :text => "The user #{@user.name} is now a " + name
		else
			render :text => "Error updating the user!"
		end
	end

	def set_review_rating
		# Get the review, user, and new rating
		user = User.find_by_id(session[:user_id])
		review = TitleReview.find_by_id(params[:review_id])
		score = params[:rating]

		unless user && review
			render :text => "No such review to rate."
			return
		end

		# Find an existing rating or create a new one
		rating = TitleRating.find(:first, :conditions => ["user_id=? and title_review_id=?", user.id, review.id])
		unless rating
			rating = TitleReviewRating.new
			rating.user_id = user.id
			rating.title_review_id = review.id
		end
		rating.rating = score
		
		# Save the rating
		if rating.save
			render :text => "Saved the title review rating."
		else
			render :text => "Error saving the title review rating." 
		end
	end

	private

	def authorize_originating_user_only
		if params[:id].to_i != session[:user_id]
			render :layout => 'default', :text => "<p id=\"flash_notice\">You don't have permission to access this page.</p>"
		end
	end
end
