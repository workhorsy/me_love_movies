#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'
require 'hpricot'

# Monkey patch Mechanize to include an Ubuntu Hardy Firefox user agent
WWW::Mechanize::AGENT_ALIASES['Ubuntu Firefox 3.0'] = 
		"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.3) Gecko/2008092510 Ubuntu/8.04 (hardy) Firefox/3.0.3"



# Get the arguments
$mode = ARGV.first

# Print the usage if there are no args
if ARGV.length == 0 || %w{ download }.include?($mode) == false
	puts "allposter_spider"
	puts "Usage: allposter_spider COMMAND"
	puts "\n"
	puts "List of Commands:\n"
	puts "download    Downloads the affiliate links, and saves "
	puts "            them in the db for that title."
	exit
end

def dl_poster_links
	# Create a browser
	agent = WWW::Mechanize.new
	agent.user_agent_alias = 'Ubuntu Firefox 3.0'

	# Go to the search page
	page = agent.get("http://www.allposters.com/gallery.asp?startat=%2Fsearchadvanced.asp")

	#form.fields.name("CategoryID").options.each do |option|
	#	form.fields.name("CategoryID").value = "Movies" if option.value == "Movies"
	#end

	# Enter the title name, and select movies and posters
	form = page.forms.with.name("form1").first
	form.fields.name("Search").first.value = "the dark knight"
	form.fields.name("CategoryID").value = "Movies"
	form.fields.name("ItemType").value = "Poster/Print"
	page = agent.submit(form)

	doc = Hpricot(page.body)
	doc.search("//img[@class='thmbd']").each do |img|
		puts img.raw_attributes['src'] if img.raw_attributes['src'].include? '~The-Dark-Knight-Posters.jpg'
	end

	raise page.images.length.inspect
	puts search_results.body
end



time_start = Time.now
puts "Started at #{time_start.to_s}"

case $mode
	when 'download':
		dl_poster_links
end

puts "Done"
time_end = Time.now
puts "Finished at #{time_end.to_s}"
puts "Total time #{(time_end - time_start).to_s}"



