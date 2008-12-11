class AdminController < ApplicationController
	layout 'default'
	before_filter :authorize_admins_only

	# GET /admin
	# GET /admin.xml
	def index
		respond_to do |format|
			format.html # index.html.erb
			#format.xml	{ render :xml => '' }
		end
	end

	# GET /admin/list_users
	# GET /admin/list_users.xml
	def list_users
		@users = User.paginate :page => params[:page], :per_page => User.per_page

		respond_to do |format|
			format.html
			#format.xml	{ render :xml => @users }
		end
	end	

	# GET /admin/list_title_reviews
	# GET /admin/list_title_reviews.xml
	def list_title_reviews
		@title_reviews = TitleReview.paginate :page => params[:page], :per_page => TitleReview.per_page

		respond_to do |format|
			format.html
			#format.xml	{ render :xml => @title_reviews }
		end
	end

	# GET /admin/list_title_ratings
	# GET /admin/list_title_ratings.xml
	def list_title_ratings
		@title_ratings = TitleRating.paginate :page => params[:page], :per_page => TitleRating.per_page

		respond_to do |format|
			format.html
			#format.xml	{ render :xml => @title_ratings }
		end
	end

	def destroy_user
		@user = User.find(params[:id])
		@user.destroy

		redirect_to :action => 'list_users'
	end

	def disable_user
		user = User.find(params[:id])
		user.disabled_reason = params[:disabled_reason]
		user.disabled = true
		user.save!

		respond_to do |format|
			format.js { head :ok }
		end
	end

	def enable_user
		user = User.find(params[:id])
		user.disabled = false
		user.save!

		respond_to do |format|
			format.js { head :ok }
		end
	end

	def scrape_titles

	end

	def _user_admin_disable
		respond_to do |format|
			format.js { render :partial => 'user_admin_disable', :locals => { :user => User.find(params[:id]) } }
		end
	end

	def _user_admin_enable
		respond_to do |format|
			format.js { render :partial => 'user_admin_enable', :locals => { :user => User.find(params[:id]) } }
		end
	end

	def _user_admin_show
		respond_to do |format|
			format.js { render :partial => 'user_admin_show', :locals => { :user => User.find(params[:id]) } }
		end
	end

	def _scrape_titles_import
		# Get the params
		link = params['link']
		scraping_broke = false
		@title = nil

		begin
			spider = SpiderWikipedia.new
			@title = spider.scrape_page(link)
			@title.save!
		rescue Exception => err
			scraping_broke = true
		end

		respond_to do |format|
			format.js do
				if scraping_broke
					render :text => "Scraping broke"
				else
					render :partial => "scrape_titles_import",
							:locals => { :title => @title }
				end
			end
		end
	end

	def _scrape_titles_edit
		respond_to do |format|
			format.js do
				render :partial => 'scrape_titles_edit', 
						:locals => { 
									:start_day => params['start_day'],
									:start_month => params['start_month'],
									:end_day => params['end_day'],
									:end_month => params['end_month'],
									:year => params['year'],
									:links => params['links']
								 }
			end
		end
	end

	def _scrape_titles_show
		# Get the params
		start_day = params['start_day'].to_i
		end_day = params['end_day'].to_i
		start_month = params['start_month'].to_i
		end_month = params['end_month'].to_i
		year = params['year'].to_i
		links = []

		require 'mechanize'
		scraping_broke = false

		begin
			month_names = %w{january february march april may june july august september october november december}

			# Monkey patch Mechanize to include an Ubuntu Hardy Firefox user agent
			WWW::Mechanize::AGENT_ALIASES['Ubuntu Firefox 3.0'] = 
					"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.3) Gecko/2008092510 Ubuntu/8.04 (hardy) Firefox/3.0.3"

			domain = "en.wikipedia.org"
			base_url = "http://www.#{domain}/wiki/#{year}_in_film"

			# Create a browser
			agent = WWW::Mechanize.new
			agent.user_agent_alias = 'Ubuntu Firefox 3.0'

			# Go to the page
			page = agent.get(base_url)

			# Grab all the tables that have title info
			tables = page.search("//table[@class='wikitable']").select do |table|
				table.search("//caption").length > 0 &&
				table.search("//caption")[0].inner_text.downcase.include?("films that achieved wide-release status after initial release")
			end

			# Grab all the titles from each row
			month, day = 0, 0
			tables.each do |table|
				# Figure out what column in this table has the title link
				title_column = nil
				counter = 1
				table.search("//tr").first.search("//td").reverse.each do |td|
					title_column = -counter if td.inner_text.downcase == "title"
					counter += 1
				end

				# Skip the first row, because it is the header
				table.search("//tr")[1..-1].each do |tr|
					# Determine what month these titles are from
					if tr.search("//td")[0]
						first_column = tr.search("//td")[0].inner_text.gsub("\n", '').downcase
						if month_names.include? first_column
							month = month_names.index(first_column)+1
						end
					end

					# Determine what day these titles are from
					if tr.search("//td")[1]
						second_column = tr.search("//td")[1].inner_text.downcase
						if second_column =~ /^\d*$/
							day = second_column.to_i
						end
					end

					# Grab the third cell from the end, then grab the link inside it
					begin
						if DateTime.parse("#{year}-#{month}-#{day}") >= DateTime.parse("#{year}-#{start_month}-#{start_day}") &&
							DateTime.parse("#{year}-#{month}-#{day}") <= DateTime.parse("#{year}-#{end_month}-#{end_day}")
							links << tr.search("//td")[title_column].search("//a")[0].raw_attributes['href'] #+ ":#{month}:#{day}"
						end
					rescue
						# FIXME: We need to not ignore titles that break the title
						#links << "brokespoded:#{month}:#{day}"
					end
				end
			end
		rescue Exception => err
			scraping_broke = true
		end

		# Get any titles that already use the same data_source as the links
		#@titles = Title.find(:all, :conditions => "data_source in(" + 
		#											links.collect { |link| "'http://en.wikipedia.org#{link}'" }.join(', ') +
		#										")")
		@links = []
		links.each do |link|
			@links << {
				:link => "http://en.wikipedia.org#{link}",
				:title => Title.find(:first, :conditions => ["data_source=?", "http://en.wikipedia.org#{link}"]) }
		end

		respond_to do |format|
			format.js do
				if scraping_broke
					render :text => "There was an error when scraping the page."
				else
					render :partial => 'scrape_titles_show', 
								:locals => { 
											:start_day => start_day,
											:start_month => start_month,
											:end_day => end_day,
											:end_month => end_month,
											:year => year,
											:links => @links
										 }
				end
			end
		end
	end
end

