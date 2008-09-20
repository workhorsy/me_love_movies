class HomeController < ApplicationController
	layout 'default'

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

		respond_to do |format|
			format.html # index.html.erb
			format.xml	{ render :xml => "" }
		end
	end
end
