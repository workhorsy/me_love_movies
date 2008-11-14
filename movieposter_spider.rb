#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'
require 'active_record'

# Monkey patch Mechanize to include an Ubuntu Hardy Firefox user agent
WWW::Mechanize::AGENT_ALIASES['Ubuntu Firefox 3.0'] = 
		"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.3) Gecko/2008092510 Ubuntu/8.04 (hardy) Firefox/3.0.3"



# Get the arguments
$mode = ARGV.first

# Print the usage if there are no args
if ARGV.length == 0 || %w{ download }.include?($mode) == false
	puts "movieposter_spider"
	puts "Usage: movieposter_spider COMMAND"
	puts "\n"
	puts "List of Commands:\n"
	puts "download    Downloads the posters, and saves "
	puts "            them in the db for that title."
	exit
end

def dl_poster_thumbs
	# Connect to the website database
	connection_format = { :adapter => 'mysql',
							:encoding => 'utf8',
							:database => 'me_love_movies_development',
							:username => 'root',
							:password => 'letmein',
							:socket => '/var/run/mysqld/mysqld.sock' } # Debian/Ubuntu
							#:socket => '/var/lib/mysql/mysql.sock' }    # Fedora
	ActiveRecord::Base.establish_connection(connection_format)

	# Load all the relevent models from the website
	%w{rating sex title title_rating title_review user user_type}.each do |file|
		require "app/models/#{file}.rb"
	end

#	for title in Title.find(:all)
		begin
			# Create a browser
			agent = WWW::Mechanize.new
			agent.user_agent_alias = 'Ubuntu Firefox 3.0'

			# Go to the search page
			page = agent.get("http://www.movieposter.com")

			form = page.forms.with.name("regsearch").first
			form.fields.name("ti").first.value = "Fight Club"
			page = agent.submit(form)

			page.search("//div[@class='divinside']").each do |div|
				poster_page = agent.click(div.search("//span[@class='img-shadow']").first.search("//a").first)
				puts poster_page.search("//span[@class='img-shadow']").first.search("//img").first.raw_attributes["src"]

				# Sleep for a bit as to not DOS movieposter.com
				#sleep(1)
			end
		end

		# Sleep for a bit as to not DOS movieposter.com
		GC.start
		sleep(2)
#	end
end



time_start = Time.now
puts "Started at #{time_start.to_s}"

case $mode
	when 'download':
		dl_poster_thumbs
end

puts "Done"
time_end = Time.now
puts "Finished at #{time_end.to_s}"
puts "Total time #{(time_end - time_start).to_s}"



