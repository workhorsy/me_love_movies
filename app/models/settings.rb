
class Settings < ActiveRecord::Base
	def self.is_beta
		beta_end_date > DateTime.now
	end

	def self.beta_end_date
		DateTime.strptime("10/31/2008", "%m/%d/%Y")
	end

	def self.beta_email_processor
		"mattjones@workhorsy.org"
	end
end
