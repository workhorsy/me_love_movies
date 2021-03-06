class TitleReviewsController < ApplicationController
	layout 'default'
	before_filter :authorize_admins_only, :only => ['destroy']
	before_filter :authorize_users_only, :only => ['new', 'create']
	before_filter :authorize_originating_user_only, :only => ['edit', 'update', '_add_title_comment', '_create_title_comment']
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
			#format.xml	{ render :xml => @title_review }
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
		@title_name = Title.find(params[:title_id]).proper_name
		@title_review.title_id = params[:title_id]

		respond_to do |format|
			format.html # new.html.erb
			#format.xml	{ render :xml => @title_review }
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
		@title_review.body = @title_review.body.gsub("\r\n", "\n")

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
				flash_notice 'The Title Review was successfully created.'
				format.html { redirect_to(@title_review) }
				#format.xml	{ render :xml => @title_review, :status => :created, :location => @title_review }
			else
				format.html { render :action => "new" }
				#format.xml	{ render :xml => @title_review.errors, :status => :unprocessable_entity }
			end
		end
	end

	# PUT /title_reviews/1
	# PUT /title_reviews/1.xml
	def update
		@title_review = TitleReview.find(params[:id])

		respond_to do |format|
			if @title_review.update_attributes(params[:title_review])
				flash_notice 'The Title Review was successfully updated.'
				format.html { redirect_to(@title_review) }
				#format.xml	{ head :ok }
			else
				format.html { render :action => "edit" }
				#format.xml	{ render :xml => @title_review.errors, :status => :unprocessable_entity }
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
			#format.xml	{ head :ok }
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

	def _list_by_title
		page = if params[:page] == nil || params[:page] == ""
			1
		else
			params[:page]
		end
		@title_id = params[:id].to_i
		@title_reviews = TitleReview.paginate(:conditions => ["title_id=?", @title_id],
											:page => page, 
											:per_page => 2, #Title::per_page, 
											:order => 'created_at desc')

		render :layout => false
	end

	def _default_title_comment
		respond_to do |format|
			format.js do
				render :partial => 'default_title_comment', 
						:locals => { 
									:element_id => params['element_id'],
									:title_id => params['title_id'],
									:review_id => params['review_id']
								 }
			end
		end
	end

	def _add_title_comment
		respond_to do |format|
			format.js do
				render :partial => 'add_title_comment', 
						:locals => { 
									:element_id => params['element_id'],
									:title_id => params['title_id'],
									:review_id => params['review_id'],
									:page => params['page']
								 }
			end
		end
	end

	def _create_title_comment
		# Get the params and make sure they exists
		title_review = TitleReview.find(params['title_review_id'])
		user = User.find(session[:user_id])
		body = params['body']

		# Create the review comment
		review_comment = ReviewComment.new
		review_comment.title_review_id = title_review.id
		review_comment.user_id = user.id
		review_comment.body = body

		respond_to do |format|
			format.js do
				if review_comment.save
					# Send the reviewer an email
					if review_comment.title_review.user.closed != true && review_comment.title_review.user.send_comment_email
						Mailer.deliver_comment_to_reviewer(
													review_comment.title_review.user.id, 
													review_comment.title_review.user.email, 
													review_comment.title_review.user.user_name,
													review_comment.user.id, 
													review_comment.user.user_name, 
													get_server_url(request), 
													review_comment.title_review.title.proper_name)
					end

					render :partial => 'default_title_comment', 
							:locals => { 
										:element_id => params['element_id'],
										:title_id => params['title_id'],
										:review_id => params['review_id'],
										:page => params['page'],
										:refresh_everything => true
									 }
				else
					render :text => "fail" + review_comment.errors.inspect
					return
					render :partial => 'error_title_comment', 
							:locals => { 
										:element_id => params['element_id'],
										:title_id => params['title_id'],
										:review_id => params['review_id']
									 }
				end
			end
		end
	end

	private

	def get_originating_user_id
		review_id = params[:title_review_id] || params[:review_id] || params[:id]
		review = TitleReview.find_by_id(review_id)
		review.user.id
	end
end

