class TitlesController < ApplicationController
	layout 'default'

	# GET /titles
	# GET /titles.xml
	def index
		@titles = Title.find(:all)

		respond_to do |format|
			format.html # index.html.erb
			format.xml	{ render :xml => @titles }
		end
	end

	# GET /titles/1
	# GET /titles/1.xml
	def show
		@title = Title.find(params[:id])
		@users = User.find(:all)
		@title_reviews = TitleReview.find(:all, :conditions => ["title_id=?", @title.id])

		respond_to do |format|
			format.html # show.html.erb
			format.xml	{ render :xml => @title }
		end
	end

	# GET /titles/new
	# GET /titles/new.xml
	def new
		@title = Title.new

		respond_to do |format|
			format.html # new.html.erb
			format.xml	{ render :xml => @title }
		end
	end

	# POST /titles
	# POST /titles.xml
	def create
		@title = Title.new(params[:title])

		respond_to do |format|
			if @title.save
				flash[:notice] = 'Title was successfully created.'
				format.html { redirect_to(@title) }
				format.xml	{ render :xml => @title, :status => :created, :location => @title }
			else
				format.html { render :action => "new" }
				format.xml	{ render :xml => @title.errors, :status => :unprocessable_entity }
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
				flash[:notice] = 'Title was successfully updated.'
				format.html { redirect_to(@title) }
				format.xml	{ head :ok }
			else
				format.html { render :action => "edit" }
				format.xml	{ render :xml => @title.errors, :status => :unprocessable_entity }
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
			format.xml	{ head :ok }
		end
	end

	# GET /titles/search
	# GET /titles/search.xml
	def search
		@title_rating = TitleRating.new
		@titles = nil

		# Just return unless this is the post back from the search button
		return unless request.post?

		# Make sure something was selected
		if params[:title_rating].values.uniq == [""]
			respond_to do |format|
				flash[:notice] = "No search parameters were selected"
				format.html { render :action => "search" }
				format.xml	{ render :xml => @title_rating.errors, :status => :unprocessable_entity }
			end
			return
		end

		# Generate a rating object from our search
		@title_rating = TitleRating.new(params[:title_rating])

		# Get only the fields that are not nil
		fields = (Title::genres + Title::attributes)
		selected_fields = fields.select { |f| @title_rating.send(f) }

		# FIXME: This should not be done each time there is a search. Instead have rake do it every minute or so
		# or use memcached
		# Update the averages of all the titles
		Title.find(:all).each do |title|
			avgs = ActiveRecord::Base.connection.select_all(
					"select " + fields.collect { |f| "Avg(#{f})" }.join(', ') + " from title_ratings where title_id = #{title.id}").first
			
			fields.each do |f|
				title.send("avg_#{f}=", avgs["Avg(#{f})"])
			end

			title.save!
		end

		@titles = Title.find(:all, :conditions => [
													selected_fields.collect { |f| "avg_#{f}=?" }.join(' or '),
													*selected_fields.collect { |f| @title_rating.send(f) }
													],
								:order => selected_fields.collect { |f| "avg_#{f}" }.join(', '),
								:limit => 10)
	end
end


