
require 'rubygems'
require 'mechanize'
require 'mini_magick'

# Monkey patch Mechanize to include an Ubuntu Hardy Firefox user agent
WWW::Mechanize::AGENT_ALIASES['Ubuntu Firefox 3.0'] = 
		"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.3) Gecko/2008092510 Ubuntu/8.04 (hardy) Firefox/3.0.3"


class SpiderMoviePoster
	DOMAIN = "movieposter.com"
	BASE_URL = "http://www.#{DOMAIN}/"

	def scrape_from_title(title)
		has_retried = false

		begin
			# Create a browser
			agent = WWW::Mechanize.new
			agent.user_agent_alias = 'Ubuntu Firefox 3.0'

			# Make sure all the directories exists
			Dir.mkdir "public/posters/" unless File.directory? "public/posters/"
			Dir.mkdir "public/posters/big/" unless File.directory? "public/posters/big/"
			Dir.mkdir "public/posters/small/" unless File.directory? "public/posters/small/"

			# Go to the search page
			page = agent.get(BASE_URL)

			# Enter the title name and submit the form
			form = page.forms.with.name("regsearch").first
			form.fields.name("ti").first.value = title.proper_name
			page = agent.submit(form)

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

				big_image_file = "public/posters/big/#{title.id}/#{number}.jpg"
				small_image_file = "public/posters/small/#{title.id}/#{number}.jpg"

				# Download and save the image
				Net::HTTP.start(DOMAIN) do |http|
					begin
						# Make the dir for the title
						Dir.mkdir "public/posters/big/#{title.id}" unless File.directory? "public/posters/big/#{title.id}"
						Dir.mkdir "public/posters/small/#{title.id}" unless File.directory? "public/posters/small/#{title.id}"

						resp = http.get(image_url)
						puts "Failed to get '#{big_image_file}'" and next unless resp.code == '200'

						# Save the image
						open("#{big_image_file}", "wb") do |file|
							file.write(resp.body)
						end
						puts "\tdownloaded: '#{title.proper_name}' : '#{big_image_file}'"
					rescue Exception => err
						# Just ignore any errors
					end
				end

				# Save a samall copy of the image
				begin
					Dir.mkdir "public/posters/small/#{title.id}" unless File.directory? "public/posters/small/#{title.id}"
					image = MiniMagick::Image.from_file(big_image_file)
					image.resize("115x153")
					image.write(small_image_file)
				rescue
				end

				# Save the poster model
				poster = Poster.new
				poster.title_id = title.id
				poster.small_image_file = small_image_file.gsub(/^public\//, '')
				poster.big_image_file = big_image_file.gsub(/^public\//, '')
				poster.product_id = poster_id
				poster.save!

				number += 1
			end
		rescue NoMethodError => err
			# Retry if we got that mechanize error that always happens the first time.
			retry if has_retried==false and err.message.downcase.include? "undefined method `meth_sym'"
			has_retried = true
		end
	end
end

