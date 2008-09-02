class TitleReviewRating < ActiveRecord::Base
	belongs_to :user
	belongs_to :title_review

	validates_presence_of :user, :title_review
end
