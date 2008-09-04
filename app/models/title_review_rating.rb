class TitleReviewRating < ActiveRecord::Base
	belongs_to :user
	belongs_to :title_review

	validates_presence_of :user, :title_review

	def after_create
		update_rating_average
	end

	def after_update
		update_rating_average
	end

	def after_destroy
		update_rating_average
	end

	def update_rating_average
		ActiveRecord::Base.connection.execute(
			"update title_reviews set " +
			"avg_user_rating = (select avg(rating) from title_review_ratings where title_review_id=#{self.title_review.id})" +
			"where id=#{self.title_review.id};")
	end
end
