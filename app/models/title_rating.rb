class TitleRating < ActiveRecord::Base
	belongs_to :title
	belongs_to :user

	validates_presence_of :user, :title
	validate :is_at_least_one_rating

	def is_at_least_one_rating
		fields = Title::genres + Title::attributes

		are_ratings = false
		fields.each do |field|
			are_ratings = true if self.send(field)
		end

		# If all the fields were blank, show the error
		errors.add_to_base("At least one rating must be selected.") unless are_ratings
	end
end
