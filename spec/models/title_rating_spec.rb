require File.dirname(__FILE__) + '/../spec_helper'

describe TitleRating do
  before(:each) do
    @title_rating = TitleRating.new
  end

  it "should be valid" do
    @title_rating.should be_valid
  end
end
