
require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'active_record'


# Create a user agent to make the sites think this is a browser
$url_prefix = "http://en.wikipedia.org"
$user_agent = "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.1) Gecko/2008072820 Hardy/8.04 (hardy) Firefox/3.0.1"

def get_movie_page_from_url(page_url)
	Hpricot(open($url_prefix + page_url, 'User-Agent' => $user_agent))
end

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
				return row.search("td")[0].innerText.gsub("\n", ', ').gsub(',,', ',')
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
				return row.search("td")[0].innerText.gsub("\n", ', ').gsub(',,', ',')
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
				return row.search("td")[0].innerText.gsub("(United States)", "").strip
			end
		end
	end

	return nil
end

def get_movie_name(doc)
	doc.search("//table[@class='infobox vevent']").each do |table|
		return table.search("tr").search("th").first.innerText
	end

	return nil
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

	# If that failed, try parsing it as a long date
	begin
		month.downcase!
		month = months.index(month)+1 if months.include? month
		return Date.strptime("#{year}-#{month}-#{day}")
	rescue
		puts "Failed: Date broke with '#{value}'"
	end
end

# Connect to the website database
connection_format = { :adapter => 'mysql',
						:encoding => 'utf8',
						:database => 'me_love_movies_development',
						:username => 'root',
						:password => 'letmein',
						:socket => '/var/run/mysqld/mysqld.sock'}
ActiveRecord::Base.establish_connection(connection_format)

# Load all the models from the website
%w{rating sex title title_rating title_review user user_type}.each do |file|
	require "app/models/#{file}.rb"
end

# Get all the contents pages
contents =
%w{A B C D E F G H I J-K L M N-O P Q R S T U-V-W X-Y-Z numbers}.collect do |n|
	"/wiki/List_of_films:_#{n}"
end

# Scrape each film and add it to the database
contents.each do |contents_page_url|
	urls = get_movies_from_contents(contents_page_url)
	urls.each do |page_url|
		doc = get_movie_page_from_url(page_url)

		name = get_movie_name(doc)
		release_date = get_movie_release_date(doc)
		director = get_movie_director(doc)
		cast = get_movie_cast(doc)
		runtime = get_movie_runtime(doc)
		#premise = get_movie_story(doc)

		#puts [name, release_date, director, cast, runtime].inspect

		title = Title.new
		title.name = name
		title.release_date = format_date(release_date)
		title.rating = "U"
		title.director = director
		title.cast = cast
		title.runtime = runtime.to_i
		#title.premise = premise

		# Determine if we should add the date to the name
		include_year = false
		Title.connection.execute("SELECT count(*) FROM `titles` WHERE name like '#{name}(____)' Or name like '#{name}';").each do |n|
			include_year = true if n.first.to_i > 0
			break
		end

		# If there is another title with the same name, add its date to the name
		other_title = Title.find_by_name(name)
		if other_title
			if other_title.update_attributes(:name => "#{other_title.name}(#{other_title.release_date.year})")
				puts "Renamed: #{name} to #{other_title.name}"
			end
		end

		# Change the name to include the year if needed
		if include_year
			title.name += "(#{title.release_date.year})"
		end

		if title.save
			puts "Saved: '#{title.name}'"
		else
			puts "Failed: '#{page_url}' " + title.errors.inspect
		end
	end
end




