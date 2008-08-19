class TitleReview < ActiveRecord::Base
	belongs_to :title
	belongs_to :user

	validates_presence_of :user, :title, :body
end
