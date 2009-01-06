class HomeController < ApplicationController
	layout 'default'
	before_filter :authorize_admins_only, :only => ['_box_office_love_edit']

	# GET /home
	# GET /home.xml
	def index
		# Get 3 random title categories
		categories = Title::genres + Title::attributes
		indexes = []
		while indexes.length < 3
			value = rand(categories.length)
			indexes << value unless indexes.include? value
		end

		@random_categories = indexes.collect do |i|
			categories[i]
		end

		# Get the top titles for those categories
		@titles = {}
		@random_categories.each do |category|
			@titles[category] = Title.find(:all, 
											:conditions => ["avg_#{category}!=?", "NULL"],
											:order => "avg_#{category} desc",
											:limit => 5)
		end

		# Get the top reviews
		@top_reviews = TitleReviewRating.find(
								:all, 
								:conditions => ["rating!=?", "NULL"],
								:order => "rating desc",
								:limit => 5,
								:include => 'title_review').collect do |rating|
									rating.title_review
								end

		# Get the titles that are opening soon. release_date > today limit 9
		@titles_opening_soon = Title.find(:all, :conditions => ["release_date>?", Time.now], :order => 'release_date asc', :limit => 9)

		@box_office_love_titles = BoxOfficeLoveTitle.find(:all)

		# Get the total number of titles, users, reviews, and ratings.
		@total_titles = Title.count
		@total_users = User.count
		@total_reviews = TitleReview.count
		@total_ratings = TitleRating.count

		respond_to do |format|
			format.html # index.html.erb
			#format.xml	{ render :xml => "" }
		end
	end

	def about
	end

	def contact
	end

	def privacy_policy
	end

	def terms_of_service
	end
	
	def why_sign_up
	end

	def _box_office_love_edit
		# Get all the titles that have been out for at lease a month.
		# Also get all the titles that were in the previous BOL.
		@titles = Title.find(:all, 
							:conditions => ["release_date < ? and release_date > ? or id in (?)", 
										DateTime.now, 
										DateTime.now - 1.month,
										BoxOfficeLoveTitle.find(:all).collect { |n| n.title_id }.join(',')], 
							:order => 'name')

		respond_to do |format|
			format.js { render :partial => 'box_office_love_edit', 
								:locals => { :titles => @titles }
						}
		end
	end

	def _box_office_love_update
		# Get all the titles and their amounts
		title_ids = params['titles'].split(';')
		amounts = params['amounts'].split(';')

		# Find all the titles
		titles = Title.find(title_ids)

		# Delete the old BoxOfficeLoveTitles
		BoxOfficeLoveTitle.find(:all).each do |t|
			t.destroy
		end

		# Save the new BoxOfficeLoveTitles
		i=0
		titles.each do |title|
			box_office_love_title = BoxOfficeLoveTitle.new
			box_office_love_title.title = title
			box_office_love_title.amount = amounts[i]
			box_office_love_title.save!
			i += 1
		end

		respond_to do |format|
			format.js { render :text => '' }
		end
	end

	def _box_office_love_show
		respond_to do |format|
			format.js { render :partial => 'box_office_love_show', :locals => { :box_office_love_titles => BoxOfficeLoveTitle.find(:all) } }
		end
	end
end
