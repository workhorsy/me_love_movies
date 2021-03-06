
require 'ezcrypto'
require 'base64'

class User < ActiveRecord::Base
	has_many :title_ratings
	has_many :title_reviews
	has_many :title_review_ratings
	has_many :user_tags
	has_many :review_comments

	validates_presence_of :name, :email, :user_name, :year_of_birth, :time_zone, :gender, :message => 'is required'
	validates_uniqueness_of :user_name, :email, :message => "is already used by another user"
	validates_length_of :user_name, :in => 2..30, :allow_blank => :true
	validates_format_of :year_of_birth, :with => /^\d+$/, :allow_nil => :true, :message => "is not a whole number"

	attr_accessor :password
	attr_accessor :password_confirmation
	validate :password_is_valid

	def self.per_page
		10
	end

	def self.authenticate(name, password)
		user = self.find_by_user_name(name)
		if user
			expected_password = User.encrypt_password(password, user.salt)
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
		self.hashed_password = User.encrypt_password(self.password, self.salt)
	end

	def avatar_file_or_default
		if self.closed
			"/images/closed.jpg"
		else
			self.avatar_file || "/images/noimage.jpg"
		end
	end

	def before_destroy
		# Destroy all the other user's content that is dependent on this user's reviews
		TitleReviewRating.find(:all, :conditions => ["title_review_id in (?)", self.title_reviews.collect{ |r| r.id }.join(', ')]).each do |review|
			review.destroy
		end

		# Destroy all all the stuff from this user
		self.title_ratings.each { |rating| rating.destroy }
		self.title_review_ratings.each { |review| review.destroy }
		self.title_reviews.each { |review| review.destroy }
		self.user_tags.each { |user_tag| user_tag.destroy }

		# Delete the avatar file
		if self.avatar_file && File.exist?("public#{self.avatar_file}")
			File.delete("public#{self.avatar_file}")
		end
	end

	private

	def password_is_valid
		# Just return if there was previous error
		return if errors['password'] != nil && errors['password'].length > 0

		# Skip validation if there are no changes
		return if self.id != nil && password.blank? && password_confirmation.blank?

		# Do password validation
		if password_confirmation != password
			errors.add('password', "does not match")
		elsif password.length < 6 || password.length > 12
			errors.add('password', "must be between 6 and 12 characters long")
		elsif hashed_password.blank?
			errors.add('password', "is required")
		end
	end

	def self.encrypt_password(password, salt)
		Base64.encode64(Crypt.encrypt(password + salt))
	end

	def self.decrypt_password(hashed_password, salt)
		len = salt.length
		b = Base64.decode64(hashed_password)
		Crypt.decrypt(b)[0..-(len+1)]
	end

	def create_new_salt
		self.salt = self.object_id.to_s + rand.to_s
	end
end


