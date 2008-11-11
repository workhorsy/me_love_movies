class TitleTagsController < ApplicationController
	layout 'default'
	before_filter :authorize_admins_only, :only => ['destroy']
	before_filter :authorize_originating_user_only, :only => ['edit', 'update', 'new', 'create']

	# GET /title_tags
	# GET /title_tags.xml
	def index
		redirect_to :controller => 'home', :action => 'index'
	end

	# GET /title_tags/1
	# GET /title_tags/1.xml
	def show
		@user = User.find(params[:user_id])
		@title = Title.find(params[:id])
		@user_tags = UserTag.find(:all, :conditions => ["user_id=? and title_id=?", @user.id, @title.id])

		respond_to do |format|
			format.html # show.html.erb
			#format.xml	{ render :xml => @title_tag }
		end
	end

	# GET /title_tags/new/1
	# GET /title_tags/new/1.xml
	def new
		@user = User.find(params[:user_id])
		@title = Title.find(params[:id])
		@user_tag = UserTag.find(:first, :conditions => ["user_id=? and title_id=?", @user.id, @title.id])

		# If there are any user_tags, take us to edit instead
		if @user_tag != nil
			redirect_to :action => 'edit', :id => @title.id, :user_id => @user.id
			return
		end

		@tags = Tag.find(:all, :order => 'name')

		# Create a map of tags
		@tag_map = {}
		Tag.find(:all, :order => 'name').collect do |tag|
			@tag_map[tag] = false
		end
		@tag_map = @tag_map.sort {|a,b| a.first.name <=> b.first.name}
	end

	# POST /title_tags/1
	# POST /title_tags/1.xml
	def create
		@user = User.find(params[:user_id])
		@title = Title.find(params[:id])
		@tags = params[:tag].collect { |id, state| Tag.find(id) }

		# Delete any previous user_tags
		UserTag.find(:all, :conditions => ["user_id=? and title_id=?", @user.id, @title.id]).each do |user_tag|
			user_tag.destroy
		end

		# Save the new tags
		@tags.each do |tag|
			user_tag = UserTag.new
			user_tag.tag = tag
			user_tag.user = @user
			user_tag.title = @title
			user_tag.save!
		end

		# Destroy all the title_tags for this title
		TitleTag.find(:all, :conditions => ["title_id=?", @title.id]).each do |title_tag|
			title_tag.destroy
		end

		# Save all the title_tags for this title
		Tag.find(:all).each do |tag|
			title_tag = TitleTag.new
			title_tag.title = @title
			title_tag.count = UserTag.count(:conditions => ["title_id=? and tag_id=?", @title.id, tag.id])
			title_tag.save!
		end

		respond_to do |format|
			flash_notice 'The User Tags were successfully created.'
			format.html { redirect_to(:action => 'show', :id => @title.id, :user_id => @user.id) }
		end
	end

	# GET /title_tags/1/edit
	def edit
		@user = User.find(params[:user_id])
		@title = Title.find(params[:id])
		@user_tags = UserTag.find(:all, :conditions => ["user_id=? and title_id=?", @user.id, @title.id])
		@tags = Tag.find(:all, :order => 'name')

		# Create a map of tags, and if they have been selected or not
		@tag_map = {}
		Tag.find(:all, :order => 'name').each do |tag|
			@tag_map[tag] = false
		end
		@user_tags.each do |user_tag|
			@tag_map[user_tag.tag] = true
		end
		@tag_map = @tag_map.sort {|a,b| a.first.name <=> b.first.name}
	end

	# PUT /title_tags/1
	# PUT /title_tags/1.xml
	def update
		@user = User.find(session[:user_id])
		@title = Title.find(params[:id])
		@tags = params[:tag].collect { |id, state| Tag.find(id) }

		# Delete any previous user_tags
		UserTag.find(:all, :conditions => ["user_id=? and title_id=?", @user.id, @title.id]).each do |user_tag|
			user_tag.destroy
		end

		# Save all the new tags
		@tags.each do |tag|
			user_tag = UserTag.new
			user_tag.tag = tag
			user_tag.user = @user
			user_tag.title = @title
			user_tag.save!
		end

		# Destroy all the title_tags for this title
		TitleTag.find(:all, :conditions => ["title_id=?", @title.id]).each do |title_tag|
			title_tag.destroy
		end

		# Save all the title_tags for this title
		Tag.find(:all).each do |tag|
			title_tag = TitleTag.new
			title_tag.title = @title
			title_tag.count = UserTag.count(:conditions => ["title_id=? and tag_id=?", @title.id, tag.id])
			title_tag.save!
		end

		respond_to do |format|
			flash_notice 'The User Tags were successfully updated.'
			format.html { redirect_to(:action => 'show', :id => @title.id, :user_id => @user.id) }
		end
	end
=begin
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
		User.find(params[:user_id]).id
	end
end

