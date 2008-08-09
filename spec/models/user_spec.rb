require File.dirname(__FILE__) + '/../spec_helper'

module UserSpecHelper
	def valid_user_attributes
		{:email => 'bobrick@blah.net',
		:name => 'Bobrick Bobberton',
		:password => '01234567'}
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

	it "should be invalid without an email" do
		@user.attributes = valid_user_attributes.except(:email)
		@user.valid?.should == false
		@user.errors.on(:email).should == "is required"
		@user.email = "bobrick@bobber.org"
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

	it "should be valid with all valid attributes" do
		@user.attributes = valid_user_attributes
		@user.valid?.should == true
	end

=begin
	FIXME: More tests:
	. Make sure the email address is formatted correctly
	. Make sure the user_name is unique and exists
	. Make sure the email address has not already been used
	. Other basic tests
=end
end

