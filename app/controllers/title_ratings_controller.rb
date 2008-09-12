class TitleRatingsController < ApplicationController
	layout 'default'
	before_filter :authorize_admins_only, :only => ['destroy']
	before_filter :authorize_users_only, :only => ['new', 'create']
	before_filter :authorize_originating_user_only, :only => ['edit', 'update']

	# GET /title_ratings
	# GET /title_ratings.xml
	def index
		redirect_to :controller => 'home', :action => 'index'
	end

	# GET /title_ratings/1
	# GET /title_ratings/1.xml
	def show
		@title_rating = TitleRating.find(params[:id])

		respond_to do |format|
			format.html # show.html.erb
			format.xml	{ render :xml => @title_rating }
		end
	end

	# GET /title_ratings/new
	# GET /title_ratings/new.xml
	def new
		# If this user already has a rating for this title, have 
		# them edit the existing one instead
		user = User.find(session[:user_id])
		rating = TitleRating.find(:first, :conditions => ["user_id=? and title_id=?", user.id, params[:title_id]])
		if user && rating
			redirect_to :action => 'edit', :id => rating.id
			return
		end

		# If not, make a new rating
		@title_rating = TitleRating.new

		# Make sure there is a title id
		@title_name = Title.find(params[:title_id]).name
		@title_rating.title_id = params[:title_id]

		respond_to do |format|
			format.html # new.html.erb
			format.xml	{ render :xml => @title_rating }
		end
	end

	# GET /title_ratings/1/edit
	def edit
		@title_rating = TitleRating.find(params[:id])

		# Make sure there is a title id
		@title_name = Title.find(@title_rating.title_id).name
	end

	# POST /title_ratings
	# POST /title_ratings.xml
	def create
		@title_rating = TitleRating.new(params[:title_rating])
		@title_rating.user_id = session[:user_id]
		@title_name = Title.find(@title_rating.title_id).name
		(Title::attributes + Title::genres).each do |name|
			@title_rating.send("#{name}=", nil) if @title_rating.send(name) == 0
		end

		respond_to do |format|
			# Save the title_rating, then if there is another by the same user, undo the save and print a warning
			was_saved = false
			begin
				TitleRating.transaction do
					was_saved = @title_rating.save
					if TitleRating.count(:conditions => ["title_id=? and user_id=?", @title_rating.title_id, @title_rating.user_id]) > 1
						was_saved = false
						raise ""
					end
				end
			rescue Exception => err
				if err.message == ""
					@title_rating.errors.add_to_base("The user already has a rating for this title.")
				else
					raise
				end
			end
			if was_saved
				flash[:notice] = 'TitleRating was successfully created.'
				format.html { redirect_to(@title_rating) }
				format.xml	{ render :xml => @title_rating, :status => :created, :location => @title_rating }
			else
				format.html { render :action => "new" }
				format.xml	{ render :xml => @title_rating.errors, :status => :unprocessable_entity }
			end
		end
	end

	# PUT /title_ratings/1
	# PUT /title_ratings/1.xml
	def update
		@title_rating = TitleRating.find(params[:id])
		(Title::attributes + Title::genres).each do |name|
			params['title_rating'][name] = nil if params['title_rating'][name] == '0'
		end

		respond_to do |format|
			if @title_rating.update_attributes(params[:title_rating])
				flash[:notice] = 'TitleRating was successfully updated.'
				format.html { redirect_to(@title_rating) }
				format.xml	{ head :ok }
			else
				format.html { render :action => "edit" }
				format.xml	{ render :xml => @title_rating.errors, :status => :unprocessable_entity }
			end
		end
	end

	# DELETE /title_ratings/1
	# DELETE /title_ratings/1.xml
	def destroy
		@title_rating = TitleRating.find(params[:id])
		@title_rating.destroy

		respond_to do |format|
			format.html { redirect_to(title_ratings_url) }
			format.xml	{ head :ok }
		end
	end

	private

	def get_originating_user_id
		rating = TitleRating.find_by_id(params[:id])
		rating.user.id
	end
end


