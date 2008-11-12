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
		@user_id = session[:user_id]

		# Determine if the id is the name or id
		id_is_name = (params[:id].to_i == 0 && params[:id] != "0")

		if id_is_name
			@title = Title.find_by_name(params[:id])
			raise "Couldn't find Title with name=#{params[:id]}" unless @title
		
		else
			@title = Title.find(params[:id])
		end

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

		# Get the number of ratings
		@ratings_count = TitleRating.count(:conditions => ["title_id=?", @title.id])

		# Get the tags
		@tag_map = {}
		Tag.find(:all).each do |tag|
			title_tag = TitleTag.find(:first, :conditions => ["title_id=? and tag_id=?", @title.id, tag.id])
			@tag_map[tag] = title_tag.count if title_tag && title_tag.count > 0
		end

		# Find the biggest and smallest tags
		range, big, small, sizes, font = 0, 0, 100_000_000, 5, 3
		@tag_map.each do |tag, count|
			if count > big
				big = count
			elsif count < small
				small = count
			end
		end
		range = ((big - small) / sizes) | 1

		# Average the tags
		@tag_map.each do |tag, count|
			@tag_map[tag] = (count / range + 1) * 3 + 10
		end

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
				flash_notice 'The Title was successfully created.'
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
				flash_notice 'The Title was successfully updated.'
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

		if params[:type] == 'by_title'
			# Make sure something was selected
			s_title = params[:title].strip
			if s_title == ''
				flash_notice "No search parameters were specified."
				return
			end

			# Find the titles that match
			db_field = 'name'
			search_params = s_title.split(' ').collect { |n| n.strip }

			@titles = Title.find(:all, :conditions => [
											search_params.collect { |n| "#{db_field} like ?"}.join(' and '),
											*search_params.collect { |n| "%#{n}%"}],
								 :order => :name)
		elsif params[:type] == 'by_director'
			@person_type = "director"
			# Make sure something was selected
			s_title = params[:director].strip
			if s_title == ''
				flash_notice "No search parameters were specified."
				return
			end

			# Find the titles that match
			db_field = 'director'
			search_params = s_title.split(' ').collect { |n| n.strip }

			@titles = Title.find(:all, :conditions => [
											search_params.collect { |n| "#{db_field} like ?"}.join(' and '),
											*search_params.collect { |n| "%#{n}%"}],
								 :order => :name)

			# Get the directors that match the names
			max_titles = 100
			max_others = 20
			@person_map = {} # {'Bobrick Bobberton' : title}
			@other_persons = [] #['Fredrick Fredderson']
			@titles.each do |title|
				title.director.split(',').collect{|a| a.strip}.each do |person|
					match_count = 0
					# Find the number of matching words there are
					search_params.each do |s_param|
						match_count += 1 if person.downcase.include? s_param.downcase
					end

					if match_count == search_params.length && max_titles > 0
						@person_map[person] ||= []
						@person_map[person] << title
						max_titles -= 1
					elsif match_count > 0 && match_count < search_params.length && max_others > 0
						unless @other_persons.include? person
							@other_persons << person
							max_others -= 1
						end
					end
				end
			end

			@other_persons = @other_persons.sort
		elsif params[:type] == 'by_actor'
			@person_type = "actor"
			# Make sure something was selected
			s_title = params[:actor].strip
			if s_title == ''
				flash_notice "No search parameters were specified."
				return
			end

			# Find the titles that match
			db_field = 'cast'
			search_params = s_title.split(' ').collect { |n| n.strip }

			@titles = Title.find(:all, :conditions => [
											search_params.collect { |n| "#{db_field} like ?"}.join(' and '),
											*search_params.collect { |n| "%#{n}%"}],
								 :order => :name)

			# Get the actors that match the names
			max_titles = 100
			max_others = 20
			@person_map = {} # {'Bobrick Bobberton' : title}
			@other_persons = [] #['Fredrick Fredderson']
			@titles.each do |title|
				title.cast.split(',').collect{|a| a.strip}.each do |person|
					match_count = 0
					# Find the number of matching words there are
					search_params.each do |s_param|
						match_count += 1 if person.downcase.include? s_param.downcase
					end

					if match_count == search_params.length && max_titles > 0
						@person_map[person] ||= []
						@person_map[person] << title
						max_titles -= 1
					elsif match_count > 0 && match_count < search_params.length && max_others > 0
						unless @other_persons.include? person
							@other_persons << person
							max_others -= 1
						end
					end
				end
			end

			@other_persons = @other_persons.sort
		elsif params[:type] == 'by_rating'
			# Make sure something was selected
			if params[:title_rating].values.uniq == ["0"]
				respond_to do |format|
					flash_notice "No search parameters were selected"
					format.html { render :action => "search" }
					#format.xml	{ render :xml => @title_rating.errors, :status => :unprocessable_entity }
				end
				return
			else
				flash_notice nil
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


