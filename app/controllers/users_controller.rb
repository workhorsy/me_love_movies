class UsersController < ApplicationController
	layout 'default'

	# GET /users
	# GET /users.xml
	def index
		redirect_to :controller => 'home', :action => 'index'
	end

	# GET /users/1
	# GET /users/1.xml
	def show
		@user = User.find(params[:id])

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

	# GET /users/1/edit
	def edit
		@user = User.find(params[:id])
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

	# GET /users/list
	# GET /users/list.xml
	def list
		# FIXME: Have this require the user to be admin
		@users = User.find(:all)

		respond_to do |format|
			format.html # index.html.erb
			format.xml	{ render :xml => @users }
		end
	end
end
