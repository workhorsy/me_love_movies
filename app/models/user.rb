class User < ActiveRecord::Base
	attr_accessor :password

	#:name, :user_name, :password, :email, :year_of_birth, :time_zone, :gender
	validates_presence_of :name, :email, :password, :message => 'is required'
	validates_uniqueness_of :user_name, :email
	validates_length_of :password, :in => 6..12, :allow_nil => :true
end
