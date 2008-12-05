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

	def poster_link(title)
		# If there are no posters, use the no image
		if title.posters.length == 0
<<EOF
<div class="image_holder1">Poster</div>
EOF
		# If there are posters, show a random one
		else
			poster = title.posters[rand(title.posters.length)]
			poster_url = "http://www.movieposter.com/cgi-bin/viewPIDn.pl?acode=#{Settings.affiliate_id}&pid=#{poster.product_id}"
<<EOF
	<a class="APCTitleAnchor" href="#{poster_url}" target="_blank" title="#{title.proper_name}">
		<img src="/#{poster.big_image_file}" alt="#{title.proper_name}" border="0" width="200">
	</a>
	<br />
	<span style="font-family:verdana,arial,helvetica;font-size:10;" >
		<a class="APCTitleAnchor" href="#{poster_url}">
			Buy this poster at movieposter.com
		</a>
		<br />
	</span>
EOF
		end
	end
end
