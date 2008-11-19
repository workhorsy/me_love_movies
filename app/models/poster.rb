

class Poster < ActiveRecord::Base
	belongs_to :title

	validates_presence_of :small_image_file, :big_image_file
end


