class User < ActiveRecord::Base
	validates_presence_of :name, :user_name, :year_of_birth, :password, :time_zone, :gender, :email, :user_type
	validates_uniqueness_of :user_name, :email
end
