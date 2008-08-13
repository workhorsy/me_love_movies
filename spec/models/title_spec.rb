require File.dirname(__FILE__) + '/../spec_helper'

describe Title do
  before(:each) do
    @title = Title.new
  end

  it "should be valid" do
    @title.should be_valid
  end
end
