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
		if title.affiliate_links == nil || title.affiliate_links.length == 0
<<EOF
<div class="image_holder1">Poster</div>
EOF
		# If there are posters, show a random one
		else
			posters = title.affiliate_links.split(';')
			item_id, poster_url = posters[rand(posters.length)].split(',')
<<EOF
	<a class="APCTitleAnchor" href="http://affiliates.allposters.com/link/redirect.asp?item=#{item_id}&AID=#{Settings.affiliate_id}&PSTID=1&LTID=2&lang=1" target="_blank" title="#{title.proper_name}">
		<img src="#{poster_url}" alt="#{title.proper_name}" border="0" height="300" width="">
	</a>
	<img src="http://tracking.allposters.com/allposters.gif?AID=#{Settings.affiliate_id}&PSTID=1&LTID=2&lang=1" border="0" height="1" width="1">
	<br />
	<span style="font-family:verdana,arial,helvetica;font-size:10;" >
		<a class="APCTitleAnchor" href="http://affiliates.allposters.com/link/redirect.asp?item=#{item_id}&AID=#{Settings.affiliate_id}&PSTID=1&LTID=2&lang=1" target="_blank" title="#{title.proper_name}">
			Buy this poster at AllPosters.com
		</a>
		<br />
	</span>
EOF
		end
	end
end
