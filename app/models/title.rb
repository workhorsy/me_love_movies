
require 'date'

class Title < ActiveRecord::Base
	attr_accessor :release_date_year, :release_date_month, :release_date_day

	validates_presence_of :name, :rating
	validates_uniqueness_of :name
	validates_length_of :name, :in => 2..255, :allow_blank => :true

	def runtime_minutes=(value)
		@runtime_minutes = value.to_i
	end

	def runtime_minutes
		@runtime_minutes
	end

	def runtime_hours=(value)
		@runtime_hours = value.to_i
	end

	def runtime_hours
		@runtime_hours
	end

	def runtime
		return nil unless @runtime_minutes || @runtime_hours
		(@runtime_minutes || 0) + (@runtime_hours || 0) * 60
	end

	def runtime=(value)
		value = value.to_i
		@runtime_hours = value / 60
		@runtime_minutes = value % 60
	end

	def release_date_year=(value)
		@release_date_year = value.to_i if value
		update_release_date
	end

	def release_date_year
		@release_date_year
	end

	def release_date_month=(value)
		@release_date_month = value.to_i if value
		update_release_date
	end

	def release_date_month
		@release_date_month
	end

	def release_date_day=(value)
		@release_date_day = value.to_i if value
		update_release_date
	end

	def release_date_day
		@release_date_day
	end

	def update_release_date
		return nil unless @release_date_year && @release_date_month && @release_date_day
		begin
			self.release_date = Date.strptime(("#{@release_date_year || 0}/#{@release_date_month || 0}/#{@release_date_day || 0}"), '%Y/%m/%d')
		rescue
			nil		
		end
	end
end


