


class Tag < ActiveRecord::Base
	has_many :title_tags
	has_many :user_tags

	validates_presence_of :name
	validates_uniqueness_of :name
	validates_length_of :name, :in => 2..255, :allow_blank => :true

	def self.per_page
		20
	end

	def before_destroy
		# Delete all the title_tags that use this tag
		self.title_tags.each do |title_tag|
			title_tag.destroy
		end
	end
end


