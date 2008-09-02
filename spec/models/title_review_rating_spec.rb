require File.dirname(__FILE__) + '/../spec_helper'

describe TitleReviewRating do
  before(:each) do
    @title_review_rating = TitleReviewRating.new
  end

  it "should be valid" do
    @title_review_rating.should be_valid
  end
end
