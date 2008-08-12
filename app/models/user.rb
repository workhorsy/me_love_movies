
require 'digest/sha1'

class User < ActiveRecord::Base
	validates_presence_of :name, :email, :user_name, :year_of_birth, :time_zone, :gender, :message => 'is required'
	validates_uniqueness_of :user_name, :email, :message => "is already used by another user"
	validates_length_of :password, :in => 6..12, :allow_nil => :true
	validates_length_of :user_name, :in => 2..30, :allow_nil => :true
	validates_format_of :year_of_birth, :with => /^\d+$/, :allow_nil => :true, :message => "is not a whole number"

	attr_accessor :password
	attr_accessor :password_confirmation
	validate :password_is_valid


	def self.authenticate(name, password)
		user = self.find_by_user_name(name)
		if user
			expected_password = encrypted_password(password, user.salt)
			if user.hashed_password != expected_password
				user = nil
			end
		end
		user
	end

	def password
		@password
	end

	def password=(value)
		@password = value
		return if value.blank?
		create_new_salt
		self.hashed_password = User.encrypted_password(self.password, self.salt)
	end

	private

	def password_is_valid
		return if errors['password'] != nil && errors['password'].length > 0

		if password_confirmation != password
			errors.add_to_base("Passwords do not match")
		elsif hashed_password.blank?
			errors.add_to_base("Missing password")
		end
	end

	def self.encrypted_password(password, salt)
		string_to_hash = password + "wibble" + salt
		Digest::SHA1.hexdigest(string_to_hash)
	end

	def create_new_salt
		self.salt = self.object_id.to_s + rand.to_s
	end
end


