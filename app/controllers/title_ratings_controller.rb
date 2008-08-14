class TitleRatingsController < ApplicationController
	layout 'default'

	# GET /title_ratings
	# GET /title_ratings.xml
	def index
		@title_ratings = TitleRating.find(:all)

		respond_to do |format|
			format.html # index.html.erb
			format.xml	{ render :xml => @title_ratings }
		end
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
		@title_rating = TitleRating.new

		respond_to do |format|
			format.html # new.html.erb
			format.xml	{ render :xml => @title_rating }
		end
	end

	# GET /title_ratings/1/edit
	def edit
		@title_rating = TitleRating.find(params[:id])
	end

	# POST /title_ratings
	# POST /title_ratings.xml
	def create
		@title_rating = TitleRating.new(params[:title_rating])

		respond_to do |format|
			if @title_rating.save
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
end
