
require 'date'

class Title < ActiveRecord::Base
	has_many :title_ratings
	has_many :title_tags
	has_many :user_tags
	has_many :posters
	has_many :box_office_love_titles

	attr_accessor :runtime_hours
	attr_accessor :runtime_minutes

	validates_presence_of :name, :rating
	validates_uniqueness_of :name
	validates_length_of :name, :in => 2..255, :allow_blank => :true

	def self.per_page
		20
	end

	def self.genres
		%w{action comedy drama scifi romance musical kids adventure 
				mystery suspense horror fantasy tv war western sports}
	end

	def self.attributes
		%w{premise plot music acting special_effects pace 
				character_dev cinematography}
	end

	def random_small_image_file
		posters = self.posters
		return "images/noposter.jpg" if posters.length == 0

		posters[rand(posters.length)].small_image_file
	end

	def random_big_image_file
		posters = self.posters
		return "images/noposter.jpg" if posters.length == 0

		posters[rand(posters.length)].big_image_file
	end

	def proper_name
		value = self.name

		# Move 'the' to the front
		if value.downcase[-5, 5] == ", the"
			return "The " + value[0 .. -6]
		end

		# Move 'A' to the front
		if value.downcase[-3, 3] == ", a"
			return "A " + value[0 .. -4]
		end

		# Move 'An' to the front
		if value.downcase[-4, 4] == ", an"
			return "An " + value[0 .. -5]
		end

		return value
	end

	def unproper_name
		self.name.split(',').first
	end

	def runtime_minutes
		@runtime_minutes
	end

	def runtime_hours
		@runtime_hours
	end

	def release_date_year
		@release_date_year
	end

	def release_date_month
		@release_date_month
	end

	def release_date_day
		@release_date_day
	end

	def runtime_minutes=(value)
		@runtime_minutes = value.to_i unless value.blank?
		update_runtime
	end

	def runtime_hours=(value)
		@runtime_hours = value.to_i unless value.blank?
		update_runtime
	end

	def release_date_year=(value)
		@release_date_year = value.to_i unless value.blank?
		update_release_date
	end

	def release_date_month=(value)
		@release_date_month = value.to_i unless value.blank?
		update_release_date
	end

	def release_date_day=(value)
		@release_date_day = value.to_i unless value.blank?
		update_release_date
	end

	def update_for_edit
		if self.release_date
			@release_date_year = self.release_date.year
			@release_date_month = self.release_date.month
			@release_date_day = self.release_date.day
		end
		if self.runtime
			@runtime_minutes = self.runtime % 60
			@runtime_hours = self.runtime / 60
		end
	end

	private

	def update_runtime
		if @runtime_minutes == nil && @runtime_hours == nil
			self.runtime = nil
		else
			self.runtime = (@runtime_minutes || 0) + (@runtime_hours || 0) * 60
		end
	end

	def update_release_date
		if @release_date_year == nil && @release_date_month == nil && @release_date_day == nil
			self.release_date = nil
		else
			begin
				self.release_date = Date.strptime(("#{@release_date_year || 0}/#{@release_date_month || 0}/#{@release_date_day || 0}"), '%Y/%m/%d')
			rescue
			end
		end
	end
end


