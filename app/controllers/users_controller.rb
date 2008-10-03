require 'cgi'

class UsersController < ApplicationController
	layout 'default'
	before_filter :authorize_admins_only, :only => ['destroy']
	before_filter :authorize_originating_user_only, :only => ['edit', 'update']

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

		# FIXME: For now we are dissabling the user email activation. Instead we are logging in the user automatically
		# FIXME: Remove this when the email activation is working
		@user.is_email_activated = true

		respond_to do |format|
			if @user.save
				@user = User.find(@user.id)

				# Send the email
				# FIXME: Uncomment this when the email activation is working
#				@server_domain = "http://" + request.env_table['HTTP_HOST']
#				Mailer.deliver_user_created(@user.id, @server_domain, @user.user_name, @user.name, @user.email)

#				flash[:notice] = 'The User was created. Check your email for the activation link.'

				# FIXME: Remove this when the email activation is working
				session[:user_id] = @user.id
				cookies[:user_name] = { :value => @user.name }
				cookies[:user_greeting] = { :value => 'Howdy' }
				cookies[:user_type] = { :value => @user.user_type }
				cookies[:user_id] = { :value => @user.id.to_s }
	 			flash[:notice] = 'The User was created. You are now logged in.'
				redirect_to(:controller => 'home', :action => :index)
				return

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
				flash[:notice] = 'The User was successfully updated.'
				format.html { redirect_to(@user) }
				format.xml	{ head :ok }
			else
				format.html { render :action => "edit" }
				format.xml	{ render :xml => @user.errors, :status => :unprocessable_entity }
			end
		end
	end

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

	# GET /users/login
	# GET /users/login.xml
	def login
		session[:user_id] = nil
		cookies[:user_name] = nil
		cookies[:user_greeting] = nil
		cookies[:user_type] = nil
		cookies[:user_id] = nil
		return unless request.post?

		# Get the user if the name and password are correct
		user = User.authenticate(params[:user_name], params[:password])

		# Flash them a fail message if the user is nil
		if user == nil
			flash[:notice] = "Login failed. Try again."

		# Make sure the user has been activated via email
		elsif user && user.is_email_activated == false
			flash[:notice] = "Before you can login, this user must be activated via the email message that was sent when the user was created."

		# Log the user in and show a success message
		elsif user && user.is_email_activated == true
			session[:user_id] = user.id
			cookies[:user_name] = { :value => user.name }
			cookies[:user_greeting] = { :value => 'Howdy' }
			cookies[:user_type] = { :value => user.user_type }
			cookies[:user_id] = { :value => user.id.to_s }
 			flash[:notice] = "Successfully loged in."
			redirect_to(:controller => 'home', :action => :index)
		end
	end

	# GET /users/logout
	# GET /users/logout.xml
	def logout
		session[:user_id] = nil
		cookies[:user_name] = nil
		cookies[:user_greeting] = nil
		cookies[:user_type] = nil
		cookies[:user_id] = nil

		redirect_to(:controller => 'home', :action => 'index')
	end

	# GET /users/forgot_password
	# GET /users/forgot_password.xml
	def forgot_password
		user_name = params['user_name']
		email = params['email']

		# Determine if that is a valid user
		user = User.find(:first, :conditions => ["user_name=? and email=?", user_name, email])

		if user
			@server_domain = "http://" + request.env_table['HTTP_HOST']
			Mailer.deliver_forgot_password(@server_domain, user.user_name, user.email, user.password)

			flash[:notice] = "The password for '#{user_name}' has been sent to #{email}."
			redirect_to :action => 'sending_password'
		else
			@user = User.new
			flash[:notice] = "There is no user with that name and email. Try again."
			render :action => "new"
		end
	end

	# GET /users/sending_password
	# GET /users/sending_password.xml
	def sending_password

	end

	# GET /users/set_is_email_activated
	# GET /users/set_is_email_activated.xml
	def set_is_email_activated
		# Find the user based on the secret id
		user = nil
		begin
			id = Crypt.decrypt(Base64.decode64(CGI.unescape(params[:secret]))).to_i
			user = User.find(id)
		rescue
		end

		# Try updating the user, if not show a message
		if user == nil
			flash[:notice] = 'Failed to activate the user.'
			render :layout => 'default', :text => ''
		elsif user.update_attributes({ :is_email_activated => true})
			flash[:notice] = 'The User was successfully activated.'
			render :layout => 'default', :text => ''
		else
			flash[:notice] = 'There was an error when trying to activate the the user.'
			render :layout => 'default', :text => ''
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

	private 

	def get_originating_user_id
		params[:id].to_i
	end
end
