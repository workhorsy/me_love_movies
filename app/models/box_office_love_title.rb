
class BoxOfficeLoveTitle < ActiveRecord::Base
	belongs_to :title

	validates_presence_of :amount
end
