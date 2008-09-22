#!/usr/bin/env ruby

require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'active_record'
require 'net/http'


# Get the arguments
$mode = ARGV.first

# Print the usage if there are no args
if ARGV.length == 0 || %w{ download scrape }.include?($mode) == false
	puts "wikipedia_spider"
	puts "Usage: wikipedia_spider COMMAND"
	puts "\n"
	puts "List of Commands:\n"
	puts "download    Downloads the pages from wikipedia and stores them in "
	puts "            the 'wiki' directory."
	puts "scrape      Scrapes the pages located in the 'wiki' directory."
	exit
end

# Create a user agent to make the sites think this is a browser
$url_prefix = "http://en.wikipedia.org"
$user_agent = "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.1) Gecko/2008072820 Hardy/8.04 (hardy) Firefox/3.0.1"

def get_movie_page_from_url(page_url)
	Hpricot(open($url_prefix + page_url, 'User-Agent' => $user_agent))
end

def get_movie_page_from_file(file_name)
	Hpricot(open(file_name))
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

def dl_pages_from_wikipedia
	# Get all the contents pages
	contents =
	%w{A B C D E F G H I J-K L M N-O P Q R S T U-V-W X-Y-Z numbers}.collect do |n|
		"/wiki/List_of_films:_#{n}"
	end

	# Make the wiki directory if it does not exist
	Dir.mkdir('wiki') unless File.directory?('wiki')

	contents.each do |contents_page_url|
		urls = get_movies_from_contents(contents_page_url)
		urls.each do |page_url|
			# Run garbage collection in case ruby decides not to when things gets heavy
			GC.start

			Net::HTTP.start($url_prefix.gsub('http://', '')) do |http|
				begin
					resp = http.get(page_url)
					next unless resp.code == '200'
					open(page_url[1..-1] + '.html', "wb") do |file|
						file.write(resp.body)
					end
					puts "downloaded: #{page_url}"
				rescue Exception => err
					# Just ignore any errors
				end
			end

			sleep 2
		end
	end
end


def scrape_pages_into_db
	# Connect to the website database
	connection_format = { :adapter => 'mysql',
							:encoding => 'utf8',
							:database => 'me_love_movies_development',
							:username => 'root',
							:password => 'letmein',
							:socket => '/var/run/mysqld/mysqld.sock' } # Debian/Ubuntu
							#:socket => '/var/lib/mysql/mysql.sock' }    # Fedora
	ActiveRecord::Base.establish_connection(connection_format)

	# Load all the models from the website
	%w{rating sex title title_rating title_review user user_type}.each do |file|
		require "app/models/#{file}.rb"
	end

	# Make the wiki directory if it does not exist
	Dir.mkdir('wiki') unless File.directory?('wiki')

	files = (Dir.entries('wiki') - ['.', '..']).sort

	# If there are no files, print a message
	puts "There are not files to scrape." and return unless files.length > 0

	files.each do |file_name|
		# Run garbage collection in case ruby decides not to when things gets heavy
		GC.start

		# Skip any files that have the name (series) in them
		if file_name.include? '(series)'
			puts "Skipped: '#{file_name}' is a series summary"
			next
		end

		# Skip any files that are a year in film
		if file_name  =~ /\d\d\d\d_in_film/
			puts "Skipped: '#{file_name}' is a 'year in film' review page"
			next
		end

		doc = get_movie_page_from_file('wiki/' + file_name)

		# Get all the data from the file
		name = get_movie_name(doc)
		release_date = get_movie_release_date(doc)
		director = get_movie_director(doc)
		cast = get_movie_cast(doc)
		runtime = get_movie_runtime(doc)
		#premise = get_movie_story(doc)

		title = Title.new
		title.name = name
		title.release_date = release_date
		title.rating = "U"
		title.director = director
		title.cast = cast
		title.runtime = runtime.to_i
		#title.premise = premise

		# Skip anything that is a play
		if title.name == "Written\302\240by"
			puts "Skipped: '#{file_name}' is a play"
			next
		end

		# Determine if we should add the date to the name
		include_year = false
		count = Title.count(:all, :conditions => ["name like ? or name like ?", "#{name}", "#{name}(____)"])
		include_year = true if count > 0

		# If there is another title with the same name, change the older one to include the date
		other_title = Title.find_by_name(name)
		begin
			if other_title && other_title.release_date.year != title.release_date.year
				if other_title.update_attributes(:name => "#{other_title.name}(#{other_title.release_date.year})")
					puts "Renamed: '#{name}' to '#{other_title.name}'"
				end
			end

			# Change the name to include the year if needed
			if include_year
				title.name += "(#{title.release_date.year})"
			end
		rescue
			if other_title
				puts "Skipped: '#{title.name}' because of title and date conflict with '#{other_title.name}'."
			else
				puts "Skipped: '#{title.name}' because of title and date had a conflict."
			end
			next
		end

		if title.save
			puts "Saved: '#{title.name}'"
		else
			puts "Failed: '#{file_name}' " + title.errors.inspect
		end
	end
end

time_start = Time.now
puts "Started at #{time_start.to_s}"

case $mode
	when 'download':
		dl_pages_from_wikipedia
	when 'scrape':
		scrape_pages_into_db
end

puts "Done"
time_end = Time.now
puts "Finished at #{time_end.to_s}"
puts "Total time #{(time_end - time_start).to_s}"



