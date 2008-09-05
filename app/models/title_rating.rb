class TitleRating < ActiveRecord::Base
	belongs_to :title
	belongs_to :user
	has_many :title_review_ratings

	validates_presence_of :user, :title
	validate :is_at_least_one_rating

	def self.per_page
		20
	end

	def is_at_least_one_rating
		fields = Title::genres + Title::attributes

		are_ratings = false
		fields.each do |field|
			are_ratings = true if self.send(field)
		end

		# If all the fields were blank, show the error
		errors.add_to_base("At least one rating must be selected.") unless are_ratings
	end

	def after_create
		update_title_average
	end

	def after_update
		update_title_average
	end

	def after_destroy
		update_title_average
	end

	def update_title_average
		fields = (Title::genres + Title::attributes)
		ActiveRecord::Base.connection.execute(
			"update titles set " +
			fields.collect { |f| "avg_#{f}=(select Avg(#{f}) from title_ratings where title_id=#{self.title_id})" }.join(', ') +
			"where id=#{self.title_id}")
	end
end
