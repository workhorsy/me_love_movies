class User < ActiveRecord::Base
	validates_presence_of :name, :email, :user_name, :year_of_birth, :time_zone, :gender, :message => 'is required'
	validates_uniqueness_of :user_name, :email, :message => "is already used by another user"
	validates_length_of :password, :in => 6..12, :allow_nil => :true
	validates_length_of :user_name, :in => 2..30, :allow_nil => :true
	validates_format_of :year_of_birth, :with => /^\d+$/, :allow_nil => :true, :message => "is not a whole number"
end
