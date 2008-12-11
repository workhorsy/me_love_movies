
require 'rubygems'
require 'mechanize'

# Monkey patch Mechanize to include an Ubuntu Hardy Firefox user agent
WWW::Mechanize::AGENT_ALIASES['Ubuntu Firefox 3.0'] = 
		"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.3) Gecko/2008092510 Ubuntu/8.04 (hardy) Firefox/3.0.3"


class SpiderWikipedia
	def get_movies_from_contents(page_url)
		urls = []
		doc = Hpricot(open($url_prefix + page_url, 'User-Agent' => $user_agent))
		doc.search("//ul/li/i").each do |i|
			if i.search('a').length == 1 # Films with name as link
				a = i.search('a').first
				name = a.innerText
				urls << a['href']
			elsif i.parent.search('ul').length == 1 # Film series in their own list
				ul = i.parent.search('ul').first
				ul.search("li/i/a").each do |a|
					name = a.innerText
					urls << a['href']
				end
			else # Films with multiple titles from different years. Years are links
				i.parent.search('a').each do |a|
					name = i.innerText + "(#{a.innerText})"
					urls << a['href']
				end
			end
		end

		return urls
	end

	def get_movie_story(doc)
		edit_strings = ['edit section: plot', 'edit section: synopsis', 'edit section: story']

		# Get the link to the edit page
		link = nil
		doc.search("//span[@class='editsection']").each do |span|
			span.search("a").each do |child|
				if edit_strings.include? child.attributes['title'].downcase
					link = $url_prefix + child.attributes['href']
				end
			end
		end

		# print an error message if no link was found
		puts "No sections for plot, story, or synopsis were found ..." and return unless link

		# Get the title of the page
		title = (doc/"//h1[@class='firstHeading']").first.innerText

		# Get the textbox text from the edit page
		doc = Hpricot(open(link, 'User-Agent' => $user_agent))

		return (doc/"#wpTextbox1").first.innerText
	end

	def get_movie_director(doc)
		doc.search("//table[@class='infobox vevent']").each do |table|
			table.search("tr").each do |row|
				next if row.search("th").length == 0

				if row.search("th")[0].innerText.downcase == 'directed by'
					return row.search("td")[0].innerText.gsub(/\[[0-9]*\]/, '').gsub("\n", ', ').gsub(',,', ',')
				end
			end
		end

		return nil
	end

	def get_movie_cast(doc)
		doc.search("//table[@class='infobox vevent']").each do |table|
			table.search("tr").each do |row|
				next if row.search("th").length == 0

				if row.search("th")[0].innerText.downcase == 'starring'
					return row.search("td")[0].innerText.gsub(/\[[0-9]*\]/, '').gsub("\n", ', ').gsub(',,', ',')
				end
			end
		end

		return nil
	end

	def get_movie_runtime(doc)
		doc.search("//table[@class='infobox vevent']").each do |table|
			table.search("tr").each do |row|
				next if row.search("th").length == 0

				if row.search("th")[0].innerText.downcase == 'running time'
					return row.search("td")[0].innerText.gsub("min.", "").gsub("minutes", "").gsub("mins", "").chomp('[1]').strip
				end
			end
		end

		return nil
	end

	def get_movie_release_date(doc)
		doc.search("//table[@class='infobox vevent']").each do |table|
			table.search("tr").each do |row|
				next if row.search("th").length == 0

				if row.search("th")[0].innerText.downcase == 'release date(s)'
					return format_date(row.search("td")[0].innerText.gsub("(United States)", "").strip)
				end
			end
		end

		return nil
	end

	def get_movie_name(doc)
		doc.search("//table[@class='infobox vevent']").each do |table|
			return format_name(table.search("tr").search("th").first.innerText.gsub("\n", ' ').gsub(/\s+/, ' '))
		end

		return nil
	end

	def format_name(value)
		# If there are even number of quotes, remove them
		if value.count('"') % 2 == 0
			value = value.gsub('"', '')
		end
		if value.count("'") % 2 == 0
			value = value.gsub("'", '')
		end
		if value.count('“”') % 2 == 0
			value = value.gsub('“', '').gsub('”', '')
		end

		# Move 'the' to the end
		if value.downcase.index('the ') == 0
			return value[3..-1].strip + ', The'
		end

		# Move 'A' to the end
		if value.downcase.index('a ') == 0
			return value[1..-1].strip + ', A'
		end

		# Move 'An' to the end
		if value.downcase.index('an ') == 0
			return value[2..-1].strip + ', An'
		end

		return value.strip
	end

	def format_date(value)
		months = %w{january february march april may june july august september october november december}
		return unless value

		# Try parsing the date
		begin
			return Date.parse(value)
		rescue
		end

		day, month, year = value.split(' ')

		# raise if the format is unknow
		raise "Unknow date format '#{value}'" unless day || month || year

		# if it is just a year
		begin
			if day.to_i > 0 && month == nil && year == nil
				year, month, day = day, 1, 1
				return Date.strptime("#{year}-#{month}-#{day}", '%F')
			end
		rescue
		end

		# If that failed, try parsing it as a 'year (country)'
		begin
			if value =~ /^\d\d\d\d \(\w*\)$/
				index = (value =~ /\(\w*\)/) -1
				year, month, day = value[0..index].strip, 1, 1
				return Date.strptime("#{year}-#{month}-#{day}", '%F')
			end
		rescue
		end

		# If that failed, try parsing it as a long date
		begin
			month.downcase!
			month = months.index(month)+1 if months.include? month
			return Date.strptime("#{year}-#{month}-#{day}")
		rescue
			puts "Failed: Date broke with '#{value}'"
		end
	end

	def scrape_page(link)
		# Create a browser
		agent = WWW::Mechanize.new
		agent.user_agent_alias = 'Ubuntu Firefox 3.0'

		# Go to the search page
		page = agent.get(link)

		name = get_movie_name(page)
		release_date = get_movie_release_date(page)
		director = get_movie_director(page)
		cast = get_movie_cast(page)
		runtime = get_movie_runtime(page)
		#premise = get_movie_story(page)

		title = Title.new
		title.name = name
		title.release_date = release_date
		title.rating = "U"
		title.director = director
		title.cast = cast
		title.runtime = runtime.to_i
		title.data_source = link

		title
	end
end

