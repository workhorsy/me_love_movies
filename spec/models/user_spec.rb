require File.dirname(__FILE__) + '/../spec_helper'

module UserSpecHelper
	def valid_user_attributes
		{:email => 'bobrick@blah.net',
		:name => 'Bobrick Bobberton',
		:password => '01234567',
		:user_name => 'bob',
		:year_of_birth => 1983,
		:time_zone => "(UTC-12:00) International Date Line West",
		:gender => 'F'}
	end
end

describe User do
	include UserSpecHelper

	before :each do
		@user = User.new
	end

	it "should be invalid without a name" do
		@user.attributes = valid_user_attributes.except(:name)
		@user.valid?.should == false
		@user.errors.on(:name).should == "is required"
		@user.name = "Frankrick"
		@user.valid?.should == true
	end

	it "should be invalid without a user name" do
		@user.attributes = valid_user_attributes.except(:user_name)
		@user.valid?.should == false
		@user.errors.on(:user_name).should == "is required"
		@user.user_name = "Frankrick"
		@user.valid?.should == true
	end

	it "should be invalid if the user name is less than 2 characters in length" do
		@user.attributes = valid_user_attributes.except(:user_name)
		@user.valid?.should == false
		@user.user_name = "Y"
		@user.valid?.should == false
		@user.user_name = "Yo"
		@user.valid?.should == true
	end

	it "should be invalid if the user name is already used" do
		user = User.new
		user.attributes = valid_user_attributes
		user.save!

		@user.attributes = valid_user_attributes
		@user.valid?.should == false
		@user.errors.on(:user_name).should == "is already used by another user"
		@user.user_name = "Yo"
		@user.email = "other.bobrick@blah.net"
		@user.valid?.should == true
	end

	it "should be invalid without an email" do
		@user.attributes = valid_user_attributes.except(:email)
		@user.valid?.should == false
		@user.errors.on(:email).should == "is required"
		@user.email = "bobrick@bobber.org"
		@user.valid?.should == true
	end

	it "should be invalid if the email is already used" do
		user = User.new
		user.attributes = valid_user_attributes
		user.save!

		@user.attributes = valid_user_attributes
		@user.valid?.should == false
		@user.errors.on(:email).should == "is already used by another user"
		@user.email = "other.bobrick@blah.net"
		@user.user_name = "other"
		@user.valid?.should == true
	end

	it "should be invalid without a year of birth" do
		@user.attributes = valid_user_attributes.except(:year_of_birth)
		@user.valid?.should == false
		@user.errors.on(:year_of_birth).should == "is required"
		@user.year_of_birth = 1983
		@user.valid?.should == true
	end

	it "should be invalid if the password is not between 6 and 12 characters in length" do
		@user.attributes = valid_user_attributes.except(:password)
		@user.valid?.should == false
		@user.password = "1"
		@user.valid?.should == false
		@user.password = "0123456789ABCDE"
		@user.valid?.should == false
		@user.password = "01234567"
		@user.valid?.should == true
	end

	it "should be invalid without a time zone" do
		@user.attributes = valid_user_attributes.except(:time_zone)
		@user.valid?.should == false
		@user.errors.on(:time_zone).should == "is required"
		@user.time_zone = "(UTC-12:00) International Date Line West"
		@user.valid?.should == true
	end

	it "should be invalid without a gender" do
		@user.attributes = valid_user_attributes.except(:gender)
		@user.valid?.should == false
		@user.errors.on(:gender).should == "is required"
		@user.gender = "M"
		@user.valid?.should == true
	end

	it "should be valid with all valid attributes" do
		@user.attributes = valid_user_attributes
		@user.valid?.should == true
	end
end

