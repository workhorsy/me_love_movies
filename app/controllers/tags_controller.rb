
class TagsController < ApplicationController
	layout 'default'
	before_filter :authorize_admins_only, :only => ['create', 'new', 'destroy']
	before_filter :authorize_moderators_only, :only => ['edit', 'update']

	# GET /tags
	# GET /tags.xml
	def index
		@tags = Tag.paginate(:page => params[:page], :per_page => Tag::per_page, :order => :name)

		respond_to do |format|
			format.html # index.html.erb
			#format.xml	{ render :xml => @tags }
		end
	end

	# GET /tags/1
	# GET /tags/1.xml
	def show
		# Determine if the id is the name or id
		id_is_name = (params[:id].to_i == 0 && params[:id] != "0")

		if id_is_name
			@tag = Tag.find_by_name(params[:id])
			raise "Couldn't find Tag with name=#{params[:id]}" unless @tag
		else
			@tag = Tag.find(params[:id])
		end

		respond_to do |format|
			format.html # show.html.erb
			#format.xml	{ render :xml => @tag }
		end
	end

	# GET /tags/new
	# GET /tags/new.xml
	def new
		@tag = Tag.new

		respond_to do |format|
			format.html # new.html.erb
			#format.xml	{ render :xml => @tag }
		end
	end

	# POST /tags
	# POST /tags.xml
	def create
		@tag = Tag.new(params[:tag])

		respond_to do |format|
			if @tag.save
				flash_notice 'The Tag was successfully created.'
				format.html { redirect_to(@tag) }
				#format.xml	{ render :xml => @tag, :status => :created, :location => @tag }
			else
				format.html { render :action => "new" }
				#format.xml	{ render :xml => @tag.errors, :status => :unprocessable_entity }
			end
		end
	end

	# GET /tags/1/edit
	def edit
		@tag = Tag.find(params[:id])
	end

	# PUT /tags/1
	# PUT /tags/1.xml
	def update
		@tag = Tag.find(params[:id])

		respond_to do |format|
			if @tag.update_attributes(params[:tag])
				flash_notice 'The Tag was successfully updated.'
				format.html { redirect_to(@tag) }
				#format.xml	{ head :ok }
			else
				format.html { render :action => "edit" }
				#format.xml	{ render :xml => @tag.errors, :status => :unprocessable_entity }
			end
		end
	end

	# DELETE /tags/1
	# DELETE /tags/1.xml
	def destroy
		@tag = Tag.find(params[:id])
		@tag.destroy

		respond_to do |format|
			format.html { redirect_to(tags_url) }
			#format.xml	{ head :ok }
		end
	end
end


