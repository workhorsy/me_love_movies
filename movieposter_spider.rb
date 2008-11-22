#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'
require 'active_record'
require 'mini_magick'

# Monkey patch Mechanize to include an Ubuntu Hardy Firefox user agent
WWW::Mechanize::AGENT_ALIASES['Ubuntu Firefox 3.0'] = 
		"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.3) Gecko/2008092510 Ubuntu/8.04 (hardy) Firefox/3.0.3"



# Get the arguments
$mode = ARGV.first
DOMAIN = "movieposter.com"
BASE_URL = "http://www.#{DOMAIN}/"

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
	%w{rating sex title title_rating title_review user user_type poster}.each do |file|
		require "app/models/#{file}.rb"
	end

	# Make sure the poster dir exists
	Dir.mkdir 'public/posters' unless File.directory? 'public/posters'
	Dir.mkdir "public/posters/big" unless File.directory? "public/posters/big"
	Dir.mkdir "public/posters/small" unless File.directory? "public/posters/small"

	for title in Title.find(:all)
		begin
			# Create a browser
			agent = WWW::Mechanize.new
			agent.user_agent_alias = 'Ubuntu Firefox 3.0'

			# Go to the search page
			page = agent.get(BASE_URL)

			# Enter the title name and submit the form
			form = page.forms.with.name("regsearch").first
			form.fields.name("ti").first.value = title.proper_name
			page = agent.submit(form)

			puts "#{title.name}"

			number = 1
			page.search("//div[@class='divinside']").each do |div|
				# Skip any posters that do not have the exact title
				poster_title = div.search("//div[@class='divinsidealigncontent']/a/b").innerHTML
				next unless poster_title == "#{title.proper_name} poster".upcase \
							|| poster_title == "#{title.proper_name} poster".upcase.gsub('.', '') \
							|| poster_title == "#{title.unproper_name} poster".upcase

				# Skip any cards or stills
				poster_stills = div.search("//span[@class='littletext']").innerHTML
				next if poster_stills.downcase.include?("still") || poster_stills.downcase.include?("card")

				poster_page = agent.click(div.search("//span[@class='img-shadow']").first.search("//a").first)
				image_url = poster_page.search("//span[@class='img-shadow']").first.search("//img").first.raw_attributes["src"]
				poster_id = poster_page.search("//span[@class='posterid']").inner_text.split('Product ID:')[1].split("\n")[0].strip

				big_image_file = "public/posters/big/#{title.name}/#{number}.jpg"
				small_image_file = "public/posters/small/#{title.name}/#{number}.jpg"

				# Download and save the image
				Net::HTTP.start(DOMAIN) do |http|
					begin
						# Make the dir for the title
						Dir.mkdir "public/posters/big/#{title.name}" unless File.directory? "public/posters/big/#{title.name}"
						Dir.mkdir "public/posters/small/#{title.name}" unless File.directory? "public/posters/small/#{title.name}"

						resp = http.get(image_url)
						puts "Failed to get '#{big_poster_name}'" and next unless resp.code == '200'

						# Save the image
						open("#{big_poster_name}", "wb") do |file|
							file.write(resp.body)
						end
						puts "\tdownloaded: #{big_poster_name}"
					rescue Exception => err
						# Just ignore any errors
					end
				end

				# Save the poster model
				poster = Poster.new
				poster.title_id = title.id
				poster.small_image_file = small_image_file
				poster.big_image_file = big_image_file
				poster.product_id = poster_id
				poster.save!

				number += 1

				# Sleep for a bit as to not DOS movieposter.com
				sleep(1)
			end

		rescue Exception => err
			# Just ignore any errors
		end

		# Sleep for a bit as to not DOS movieposter.com
		GC.start
		sleep(1)
	end

	Poster.find(:all, :order => "id").each do |poster|
		# Resize the file
		begin
			Dir.mkdir "public/posters/small/#{poster.title.name}" unless File.directory? "public/posters/small/#{poster.title.name}"
			image = MiniMagick::Image.from_file(poster.big_image_file)
			image.resize("115x153")
			image.write(poster.small_image_file)
			puts "saved the image '#{poster.small_image_file}'"
		rescue
		end
	end
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



