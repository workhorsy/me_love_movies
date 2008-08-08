class Sex < ActiveRecord::Base
	NAMES_ABBREVIATIONS	= self.find(:all, :order => :name).map do |s|
		[s.name, s.abbreviation]
	end
end
