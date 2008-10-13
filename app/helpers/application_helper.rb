# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	def get_months_hash
		i = 0
		%w{January February March April May June July August September October November December}.collect do |m|
			i += 1
			[m, i]
		end
	end

	def star_images(value)
		# Make the count zero if it is nil.
		count = value || 0.0

		# Round the count to the nearest floor or ceiling
		count = count % 1 < 0.5 ? count.floor : count.ceil

		("<img src=\"/images/heart_on.jpg\" alt=\"\" />" * count) + 
		("<img src=\"/images/heart_off.jpg\" alt=\"\" />" * (5.0 - count))
	end

	def urls_to_hrefs(text, escape_char=';')
		# just return nil if text is nil
		return nil unless text

		# Convert all the urls into hrefs
		text.split(escape_char).collect do |t|
			t = t.strip
			t  =~ /^http:\/\// ? "<a href=\"#{t}\" target=\"_blank\">#{t}</a>" : t
		end.join(', ')
	end
end
