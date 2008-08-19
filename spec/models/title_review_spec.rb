require File.dirname(__FILE__) + '/../spec_helper'

describe TitleReview do
  before(:each) do
    @title_review = TitleReview.new
  end

  it "should be valid" do
    @title_review.should be_valid
  end
end
