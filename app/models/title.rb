
require 'date'

class Title < ActiveRecord::Base
	has_many :title_ratings

	attr_accessor :runtime_hours
	attr_accessor :runtime_minutes

	validates_presence_of :name, :rating
	validates_uniqueness_of :name
	validates_length_of :name, :in => 2..255, :allow_blank => :true

	def self.genres
		%w{action comedy drama scifi romance musical kids adventure 
				mystery suspense horror fantasy tv war western sports}
	end

	def self.attributes
		%w{premise plot music acting special_effects pace 
				character_development cinematography}
	end

	def average_rating(name)
		fields = Title::genres + Title::attributes

		# Make sure the field exists
		raise "There is no field named #{name} to rate." unless fields.include? name

		TitleRating::average(name, :conditions => ["title_id=?", self.id])
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


