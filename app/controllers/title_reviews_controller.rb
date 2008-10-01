class TitleReviewsController < ApplicationController
	layout 'default'
	before_filter :authorize_admins_only, :only => ['destroy']
	before_filter :authorize_users_only, :only => ['new', 'create']
	before_filter :authorize_originating_user_only, :only => ['edit', 'update']
	before_filter :authorize_title_is_released, :only => ['new']

	# GET /title_reviews
	# GET /title_reviews.xml
	def index
		redirect_to :controller => 'home', :action => 'index'
	end

	# GET /title_reviews/1
	# GET /title_reviews/1.xml
	def show
		@title_review = TitleReview.find(params[:id])

		respond_to do |format|
			format.html # show.html.erb
			format.xml	{ render :xml => @title_review }
		end
	end

	# GET /title_reviews/new
	# GET /title_reviews/new.xml
	def new
		# If this user already has a review for this title, have 
		# them edit the existing one instead
		user = User.find(session[:user_id])
		review = TitleReview.find(:first, :conditions => ["user_id=? and title_id=?", user.id, params[:title_id]])
		if user && review
			redirect_to :action => 'edit', :id => review.id
			return
		end

		# If not, make a new review
		@title_review = TitleReview.new

		# Make sure there is a title id
		@title_name = Title.find(params[:title_id]).name
		@title_review.title_id = params[:title_id]

		respond_to do |format|
			format.html # new.html.erb
			format.xml	{ render :xml => @title_review }
		end
	end

	# GET /title_reviews/1/edit
	def edit
		@title_review = TitleReview.find(params[:id])

		# Make sure there is a title id
		@title_name = Title.find(@title_review.title_id).name
	end

	# POST /title_reviews
	# POST /title_reviews.xml
	def create
		@title_review = TitleReview.new(params[:title_review])
		@title_review.user_id = session[:user_id]
		@title_name = Title.find(@title_review.title_id).name

		respond_to do |format|
			# Save the title_reviews, then if there is another by the same user, undo the save and print a warning
			was_saved = false
			begin
				TitleReview.transaction do
					was_saved = @title_review.save
					if TitleReview.count(:conditions => ["title_id=? and user_id=?", @title_review.title_id, @title_review.user_id]) > 1
						was_saved = false
						raise ""
					end
				end
			rescue Exception => err
				if err.message == ""
					@title_review.errors.add_to_base("The user already has a review for this title.")
				else
					raise
				end
			end
			if was_saved
				flash[:notice] = 'The Title Review was successfully created.'
				format.html { redirect_to(@title_review) }
				format.xml	{ render :xml => @title_review, :status => :created, :location => @title_review }
			else
				format.html { render :action => "new" }
				format.xml	{ render :xml => @title_review.errors, :status => :unprocessable_entity }
			end
		end
	end

	# PUT /title_reviews/1
	# PUT /title_reviews/1.xml
	def update
		@title_review = TitleReview.find(params[:id])

		respond_to do |format|
			if @title_review.update_attributes(params[:title_review])
				flash[:notice] = 'The Title Review was successfully updated.'
				format.html { redirect_to(@title_review) }
				format.xml	{ head :ok }
			else
				format.html { render :action => "edit" }
				format.xml	{ render :xml => @title_review.errors, :status => :unprocessable_entity }
			end
		end
	end

	# DELETE /title_reviews/1
	# DELETE /title_reviews/1.xml
	def destroy
		@title_review = TitleReview.find(params[:id])
		@title_review.destroy

		respond_to do |format|
			format.html { redirect_to(title_reviews_url) }
			format.xml	{ head :ok }
		end
	end

	def set_review_rating
		# Get the review, user, and new rating
		user = User.find_by_id(session[:user_id])
		review = TitleReview.find_by_id(params[:review_id])
		score = params[:rating].to_i
		score = nil if score == 0

		unless user
			render :layout => false, :text => "You have to be logged in to do that."
			return
		end

		unless review
			render :layout => false, :text => "No such review to rate."
			return
		end

		# Find an existing rating or create a new one
		rating = TitleReviewRating.find(:first, :conditions => ["user_id=? and title_review_id=?", user.id, review.id])
		unless rating
			rating = TitleReviewRating.new
			rating.user_id = user.id
			rating.title_review_id = review.id
		end
		rating.rating = score
		
		# Save the rating
		if rating.save
			render :layout => false, :text => "Saved the title review rating."
		else
			render :layout => false, :text => "Error saving the title review rating." 
		end
	end

	# GET /list_by_title/1
	# GET /list_by_title/1.xml
	def list_by_title
		@title_reviews = TitleReview.find(:all)
											#:conditions => ["title_id=?", id])
		render :layout => false
	end

	private

	def get_originating_user_id
		review = TitleReview.find_by_id(params[:id])
		review.user.id
	end
end

