class TitleTagsController < ApplicationController
	layout 'default'
	before_filter :authorize_admins_only, :only => ['destroy']
	before_filter :authorize_users_only, :only => ['new', 'create']
	before_filter :authorize_originating_user_only, :only => ['edit', 'update']

	# GET /title_tags
	# GET /title_tags.xml
	def index
		redirect_to :controller => 'home', :action => 'index'
	end

	# GET /title_tags/1
	# GET /title_tags/1.xml
	def show
		@title_tag = TitleTag.find(params[:id])

		respond_to do |format|
			format.html # show.html.erb
			#format.xml	{ render :xml => @title_tag }
		end
	end

	# GET /title_tags/new/1
	# GET /title_tags/new/1.xml
	def new
		user = User.find(session[:user_id])
		@title = Title.find(params[:id])
		@user_tags = UserTag.find(:all, :conditions => ["user_id=? and title_id=?", user.id, @title.id])

		# If there are any user_tags, take us to edit instead
		if @user_tags.length > 0
			redirect_to :action => 'edit', :id => @title_id
			return
		end

		@tags = Tag.find(:all)
	end

	# GET /title_tags/1/edit
	def edit
		user = User.find(session[:user_id])
		@title = Title.find(params[:id])
		@user_tags = UserTag.find(:all, :conditions => ["user_id=? and title_id=?", user.id, @title.id])
		@tags = Tag.find(:all)
	end

=begin
	# POST /title_tags
	# POST /title_tags.xml
	def create
		@title_tag = TitleTag.new(params[:title_tag])
		@title_tag.user_id = session[:user_id]
		@title_name = Title.find(@title_tag.title_id).name

		respond_to do |format|
			# Save the title_tags, then if there is another by the same user, undo the save and print a warning
			was_saved = false
			begin
				TitleTag.transaction do
					was_saved = @title_tag.save
					if TitleTag.count(:conditions => ["title_id=? and user_id=?", @title_tag.title_id, @title_tag.user_id]) > 1
						was_saved = false
						raise ""
					end
				end
			rescue Exception => err
				if err.message == ""
					@title_tag.errors.add_to_base("The user already has a review for this title.")
				else
					raise
				end
			end
			if was_saved
				flash_notice 'The Title Review was successfully created.'
				format.html { redirect_to(@title_tag) }
				#format.xml	{ render :xml => @title_tag, :status => :created, :location => @title_tag }
			else
				format.html { render :action => "new" }
				#format.xml	{ render :xml => @title_tag.errors, :status => :unprocessable_entity }
			end
		end
	end

	# PUT /title_tags/1
	# PUT /title_tags/1.xml
	def update
		@title_tag = TitleTag.find(params[:id])

		respond_to do |format|
			if @title_tag.update_attributes(params[:title_tag])
				flash_notice 'The Title Review was successfully updated.'
				format.html { redirect_to(@title_tag) }
				#format.xml	{ head :ok }
			else
				format.html { render :action => "edit" }
				#format.xml	{ render :xml => @title_tag.errors, :status => :unprocessable_entity }
			end
		end
	end

	# DELETE /title_tags/1
	# DELETE /title_tags/1.xml
	def destroy
		@title_tag = TitleTag.find(params[:id])
		@title_tag.destroy

		respond_to do |format|
			format.html { redirect_to(title_tags_url) }
			#format.xml	{ head :ok }
		end
	end
=end

	private

	def get_originating_user_id
		review = TitleTag.find_by_id(params[:id])
		review.user.id
	end
end

