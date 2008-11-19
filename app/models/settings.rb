
class Settings < ActiveRecord::Base
	def self.is_beta
		beta_end_date > DateTime.now
	end

	def self.beta_end_date
		DateTime.strptime("9/1/2008", "%m/%d/%Y")
	end

	def self.beta_email_processor
		"mattjones@workhorsy.org"
	end

	def self.affiliate_id
		'4902487d53b00449'
	end
end
