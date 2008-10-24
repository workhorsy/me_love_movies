

class UsersController < ApplicationController
	layout 'default'
	before_filter :authorize_admins_only, :only => ['destroy']
	before_filter :authorize_originating_user_only, :only => ['edit', 'update', 'set_avatar_file']

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

		@can_see_private_information = is_originating_user_or_admin

		respond_to do |format|
			format.html # show.html.erb
			#format.xml	{ render :xml => @user }
		end
	end

	# GET /users/new
	# GET /users/new.xml
	def new
		@user = User.new

		respond_to do |format|
			format.html # new.html.erb
			#format.xml	{ render :xml => @user }
		end
	end

	# POST /users
	# POST /users.xml
	def create
		@user = User.new(params[:user])
		@user.user_type = UserType::NAMES_ABBREVIATIONS.select { |k, v| v == 'U' }.first.last

		is_beta = Settings.is_beta

		# Determine if we have reached the beta cap
		if is_beta && User.count >= 100
			flash_notice 'Sorry. The maximum number of users for the beta test has been reached.'
			format.html { redirect_to(@user) }
			return
		end

		# Or try creating the users
		respond_to do |format|
			if @user.save
				@user = User.find(@user.id)

				# Send the email
				@server_domain = get_server_url(request)
				if is_beta
					Mailer.deliver_user_created_beta(@user.id, @server_domain, @user.user_name, @user.name, @user.email)
					flash_notice 'You are now registered in the beta. Check your email in a few hours to see if your account has been activated.'
				else
					Mailer.deliver_user_created(@user.id, @server_domain, @user.user_name, @user.name, @user.email)
					flash_notice 'The User was created. Check your email for the activation link.'
				end

				format.html { redirect_to(@user) }
				#format.xml	{ render :xml => @user, :status => :created, :location => @user }
			else
				format.html { render :action => "new" }
				#format.xml	{ render :xml => @user.errors, :status => :unprocessable_entity }
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
				flash_notice 'The User was successfully updated.'
				format.html { redirect_to(@user) }
				#format.xml	{ head :ok }
			else
				format.html { render :action => "edit" }
				#format.xml	{ render :xml => @user.errors, :status => :unprocessable_entity }
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
			#format.xml	{ head :ok }
		end
	end

	# GET /users/login
	# GET /users/login.xml
	def login
		# If the user tried to go directly to this page run the logout action
		unless request.post?
			self.logout
			return
		end

		# Clear the sessions and cookies
		login_clear_sessions_and_cookies()

		# Get the user if the name and password are correct
		user = User.authenticate(params[:user_name], params[:password])

		# Flash them a fail message if the user is nil
		if user == nil
			flash_notice "Login failed. Try again."

		# Make sure the user has been activated via email
		elsif user && user.is_email_activated == false
			if Settings.is_beta
				flash_notice "Before you can login, this user must be activated via the email message that was sent when the user was created."
			else
				flash_notice "Your account is still waiting to be approved for the beta. You will receive an email when it is processed."
			end

		# Log the user in and show a success message
		elsif user && user.is_email_activated == true
			login_set_sessions_and_cookies(user)

 			flash_notice "You are now logged in."
		end

		# Go back to the page the user came from, or the homepage
		from_same_site = (request.env_table['HTTP_REFERER'] && request.env_table['HTTP_REFERER'].index(get_server_url(request)) == 0)
		if from_same_site
			if request.env_table['HTTP_REFERER'].index("/users/beta") != nil
				redirect_to :controller => 'home', :action => 'index'
			else
				redirect_to(request.env_table['HTTP_REFERER'])
			end
		else
			redirect_to :controller => 'home', :action => 'index'
		end
	end

	# GET /users/logout
	# GET /users/logout.xml
	def logout
		login_clear_sessions_and_cookies()
		flash_notice "You are now logged out."

		# Remove the sessions and cookies. Try to go to the previous page. If there is none, or it is from a different site, go home.
		from_same_site = (request.env_table['HTTP_REFERER'] && request.env_table['HTTP_REFERER'].index(get_server_url(request)) == 0)
		if from_same_site
			redirect_to(request.env_table['HTTP_REFERER'])
		else
			redirect_to :controller => 'home', :action => 'index'
		end
	end

	# GET /users/forgot_password
	# GET /users/forgot_password.xml
	def forgot_password
		user_name = params['user_name']
		email = params['email']

		# Determine if that is a valid user
		user = User.find(:first, :conditions => ["user_name=? and email=?", user_name, email])

		if user
			@server_domain = get_server_url(request)
			Mailer.deliver_forgot_password(@server_domain, user.user_name, user.email, user.hashed_password, user.salt)

			flash_notice "The password for '#{user_name}' has been sent to #{email}."
			redirect_to :action => 'show', :id => user.id
		else
			@user = User.new
			# FIXME: Setting the flash and not refreshing, causes the error message to stick around for an extra refresh.
			flash_notice "There is no user with that name and email. Try again."
			render :action => "new"
		end
	end

	# GET /users/set_is_email_activated
	# GET /users/set_is_email_activated.xml
	def set_is_email_activated
		# Find the user based on the secret id
		user = nil
		begin
			id = Crypt.decrypt(CGI.unescape(params[:secret])).to_i
			user = User.find(id)
		rescue
		end

		# Try updating the user, if not show a message
		if user == nil
			flash_notice 'Failed to activate the user.'
			redirect_to :controller => 'home', :action => 'index'
		elsif user.update_attributes({ :is_email_activated => true})
			login_set_sessions_and_cookies(user)
			flash_notice 'The User was successfully activated. You are now logged in.'
			redirect_to :controller => 'users', :action => 'show', :id => user.id
		else
			flash_notice 'There was an error when trying to activate the the user.'
			redirect_to :controller => 'users', :action => 'show', :id => user.id
		end
	end

	def set_beta_activated
		# Find the user based on the secret id
		user = nil
		begin
			id = Crypt.decrypt(CGI.unescape(params[:secret])).to_i
			user = User.find(id)
		rescue
		end

		# Try updating the user, if not show a message
		if user == nil
			flash_notice 'Failed to activate the user for beta.'
			redirect_to :controller => 'home', :action => 'index'
		elsif user.update_attributes({ :is_email_activated => true})
			server_domain = get_server_url(request)
			Mailer.deliver_user_activated_beta(user.id, server_domain, user.user_name, user.name, user.email, user.hashed_password, user.salt)
			flash_notice 'The User was successfully activated for beta.'
			redirect_to :controller => 'users', :action => 'show', :id => user.id
		else
			flash_notice 'There was an error when trying to activate the the user for beta.'
			redirect_to :controller => 'home', :action => 'index'
		end
	end

	def set_beta_delete
		# Find the user based on the secret id
		user = nil
		#begin
			id = Crypt.decrypt(CGI.unescape(params[:secret])).to_i
			user = User.find(id)
		#rescue
		#end

		# Try delte the user, if not show a message
		if user == nil
			flash_notice 'Failed to delte the user for beta.'
			redirect_to :controller => 'home', :action => 'index'
		elsif user.destroy
			server_domain = get_server_url(request)
			Mailer.deliver_user_delete_beta(user.id, server_domain, user.user_name, user.name, user.email)
			flash_notice 'The User was successfully deleted for beta.'
			redirect_to :controller => 'home', :action => 'index'
		else
			flash_notice 'There was an error when trying to delete the the user for beta.'
			redirect_to :controller => 'home', :action => 'index'
		end
	end

	def toggle_is_email_activated
		# Make sure the user making this request is an admin
		unless User.find(session[:user_id]).user_type == 'A'
			render :text => "You are not an Administrator"
			return
		end

		# make sure the user exists
		@user = User.find_by_id(params[:id])
		unless @user
			render :text => "There is no user with the id '#{params[:id]}'."
			return
		end

		value = params['is_email_activated'] == "1" ? true : false

		if @user.update_attributes({ :is_email_activated => value})
			message = value ? 'activated' : 'deactivated'
			render :text => "The user #{@user.user_name} is now #{message}."
		else
			render :text => "Error updating the user!"
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
			render :text => "The user #{@user.user_name} is now a " + name
		else
			render :text => "Error updating the user!"
		end
	end

	# GET /users/set_avatar_file
	# GET /users/set_avatar_file.xml
	def set_avatar_file
		# Get the id and user
		id = params[:id]
		@user = User.find(id)
		file = params[:file]

		# Show an error if the file is blank
		if file == ""
			flash_notice "No avatar file was selected"
			redirect_to(@user)
			return
		end

		# Show an error if the mime type is unknown
		mime_type = file.content_type.chomp.downcase
		unless valid_image_mime_types.include? mime_type
			flash_notice "Only images can be used for avatars. This file of type '#{mime_type}' is unknown."
			redirect_to(@user)
			return
		end

		# Delete the old file
		File.delete("public#{@user.avatar_file}") if @user.avatar_file && File.exist?("public#{@user.avatar_file}")

		# Make all the directories if they do not exist
		FileUtils.mkdir('public/user_avatars') unless File.directory?('public/user_avatars')
		FileUtils.mkdir("public/user_avatars/#{id}") unless File.directory?("public/user_avatars/#{id}")

		# Save the file to disk
		File.open("public/user_avatars/#{id}/#{file.original_filename}", "wb") do |f|
			f.write(file.read)
		end

		# Resize the file
		image = MiniMagick::Image.from_file("#{RAILS_ROOT}/public/user_avatars/#{id}/#{file.original_filename}")
		image.resize("100x100")
		image.write("#{RAILS_ROOT}/public/user_avatars/#{id}/#{file.original_filename}")

		new_avatar_file = "/user_avatars/#{id}/#{file.original_filename}"

		# Save the path to the file in the users
		respond_to do |format|
			if @user.update_attributes(:avatar_file => new_avatar_file)
				flash_notice "The User's avatar was successfully updated."
				format.html { redirect_to(@user) }
				#format.xml	{ head :ok }
			else
				format.html { render :action => "edit" }
				#format.xml	{ render :xml => @user.errors, :status => :unprocessable_entity }
			end
		end
	end

	def beta
		date = Settings.beta_end_date
		@end_date = "#{date.month}/#{date.day}/#{date.year}"
	end

	private

	def login_clear_sessions_and_cookies
		session[:user_id] = nil
		cookies[:user_name] = nil
		cookies[:user_greeting] = nil
		cookies[:user_type] = nil
		cookies[:user_id] = nil
	end

	def login_set_sessions_and_cookies(user)
		greetings = ['Howdy', 'Holla', 'Bonjour', 'Guten Tag', 'Aloha', 'Konnichi Wa']
		session[:user_id] = user.id
		cookies[:user_name] = { :value => user.user_name }
		cookies[:user_greeting] = { :value => 'Howdy' }
		cookies[:user_greeting] = { :value => greetings[rand(greetings.length)] }
		cookies[:user_type] = { :value => user.user_type }
		cookies[:user_id] = { :value => user.id.to_s }
	end

	def get_originating_user_id
		params[:id].to_i
	end
end
