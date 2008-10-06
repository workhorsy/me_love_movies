class TitlesController < ApplicationController
	layout 'default'
	before_filter :authorize_admins_only, :only => ['create', 'new', 'destroy']
	before_filter :authorize_moderators_only, :only => ['edit', 'update']

	# GET /titles
	# GET /titles.xml
	def index
		@titles = Title.paginate(:page => params[:page], :per_page => Title::per_page, :order => :name)

		respond_to do |format|
			format.html # index.html.erb
			#format.xml	{ render :xml => @titles }
		end
	end

	# GET /titles/1
	# GET /titles/1.xml
	def show
		# Determine if the id is the name or id
		id_is_name = (params[:id].to_i == 0 && params[:id] != "0")

		if id_is_name
			@title = Title.find_by_name(params[:id])
			raise "Couldn't find Title with name=#{params[:id]}" unless @title
		
		else
			@title = Title.find(params[:id])
		end
=begin
		# Find all the reviews and sort them by user type
		@title_reviews = { 'user' => [], 
						'moderator' => [], 
						'critic' => [] }

		reviews = TitleReview.find(:all, :conditions => ["title_id=?", @title.id])
		reviews.each do |review|
			case review.user.user_type
				when 'U': @title_reviews['user'] << review
				when 'A', 'M': @title_reviews['moderator'] << review
				when 'C': @title_reviews['critic'] << review
			end
		end
=end
		# Find a new review
		@new_review = TitleReview.find(:all, 
										:conditions => ["title_id=?", @title.id],
										:order => "created_at desc",
										:limit => 1).first

		# Find a top review
		@top_review = TitleReview.find(:all,
										:conditions => ["title_id=?", @title.id],
										:order => "avg_user_rating desc",
										:limit => 1).first

		# Find a random critic review
		@critic_review = TitleReview.find(:all,
											:conditions => ["title_id=?", @title.id],
											:include => 'user').select do |tr|
			tr.user.user_type == 'C'
		end
		@critic_review = @critic_review[rand(@critic_review.length)]

		# If any of the showcased reviews are the same, remove the duplicates
		@top_review = nil if @critic_review && @top_review && @critic_review.id == @top_review.id
		@new_review = nil if @critic_review && @new_review && @critic_review.id == @new_review.id
		@new_review = nil if @new_review && @top_review && @new_review.id == @top_review.id

		respond_to do |format|
			format.html # show.html.erb
			#format.xml	{ render :xml => @title_reviews }
		end
	end

	# GET /titles/new
	# GET /titles/new.xml
	def new
		@title = Title.new

		respond_to do |format|
			format.html # new.html.erb
			#format.xml	{ render :xml => @title }
		end
	end

	# POST /titles
	# POST /titles.xml
	def create
		@title = Title.new(params[:title])

		respond_to do |format|
			if @title.save
				flash[:notice] = 'The Title was successfully created.'
				format.html { redirect_to(@title) }
				#format.xml	{ render :xml => @title, :status => :created, :location => @title }
			else
				format.html { render :action => "new" }
				#format.xml	{ render :xml => @title.errors, :status => :unprocessable_entity }
			end
		end
	end

	# GET /titles/1/edit
	def edit
		@title = Title.find(params[:id])
		# FIXME: This should be handled inside the model
		@title.update_for_edit
	end

	# PUT /titles/1
	# PUT /titles/1.xml
	def update
		@title = Title.find(params[:id])

		respond_to do |format|
			if @title.update_attributes(params[:title])
				flash[:notice] = 'The Title was successfully updated.'
				format.html { redirect_to(@title) }
				#format.xml	{ head :ok }
			else
				format.html { render :action => "edit" }
				#format.xml	{ render :xml => @title.errors, :status => :unprocessable_entity }
			end
		end
	end

	# DELETE /titles/1
	# DELETE /titles/1.xml
	def destroy
		@title = Title.find(params[:id])
		@title.destroy

		respond_to do |format|
			format.html { redirect_to(titles_url) }
			#format.xml	{ head :ok }
		end
	end

	# GET /titles/search
	# GET /titles/search.xml
	def search
		@title_rating = TitleRating.new
		@titles = nil

		# Just return unless this is the post back from the search button
		return unless request.post?

		if params[:type] == 'by_name'
			# Make sure something was selected
			s_name = params[:name].strip
			s_actor = params[:actor].strip
			s_director = params[:director].strip
			if [s_name, s_actor, s_director].uniq == ['']
				respond_to do |format|
					flash[:notice] = "No search parameters were selected"
					format.html { render :action => "search" }
					#format.xml	{ render :xml => @title_rating.errors, :status => :unprocessable_entity }
				end
				return
			else
				flash[:notice] = nil
			end

			# Do the search by category
			db_field, search_params = nil, nil
			if s_name != ''
				db_field, search_params = 'name', s_name
			elsif s_actor != ''
				db_field, search_params = 'cast', s_actor
			elsif s_director != ''
				db_field, search_params = 'director', s_director
			end

			search_params = search_params.split(' ').collect { |n| n.strip }

			@titles = Title.find(:all, :conditions => [
											search_params.collect { |n| "#{db_field} like ?"}.join(' and '),
											*search_params.collect { |n| "%#{n}%"}],
								 :order => :name)

		elsif params[:type] == 'by_rating'
			# Make sure something was selected
			if params[:title_rating].values.uniq == ["0"]
				respond_to do |format|
					flash[:notice] = "No search parameters were selected"
					format.html { render :action => "search" }
					#format.xml	{ render :xml => @title_rating.errors, :status => :unprocessable_entity }
				end
				return
			else
				flash[:notice] = nil
			end

			# Generate a rating object from our search
			@title_rating = TitleRating.new(params[:title_rating])

			# Get only the fields that were not blank
			fields = (Title::genres + Title::attributes)
			selected_fields = fields.select { |f| @title_rating.send(f) }

			# Find the titles that have matching field values. Order by most matching.
			@titles = Title.find(:all, :conditions => [
														selected_fields.collect { |f| "avg_#{f}=?" }.join(' or '),
														*selected_fields.collect { |f| @title_rating.send(f) }
														],
									:order => selected_fields.collect { |f| "avg_#{f}" }.join(', ')).reverse
		end
	end
end


