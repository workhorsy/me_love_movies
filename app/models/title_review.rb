class TitleReview < ActiveRecord::Base
	belongs_to :title
	belongs_to :user

	def self.max_body_length
		1000
	end

	validates_presence_of :user, :title, :body
	validates_length_of :body, :in => 2..TitleReview::max_body_length, :allow_blank => :true
end
