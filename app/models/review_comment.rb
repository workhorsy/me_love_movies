class ReviewComment < ActiveRecord::Base
	belongs_to :title_review
	belongs_to :user

	def self.max_body_length
		1000
	end

	validates_presence_of :user, :title_review, :body
	validates_length_of :body, :in => 2..ReviewComment::max_body_length, :allow_blank => :true
end
