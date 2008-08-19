require File.dirname(__FILE__) + '/../../spec_helper'

describe "/title_reviews/show.html.erb" do
  include TitleReviewsHelper
  
  before(:each) do
    @title_review = mock_model(TitleReview)
    @title_review.stub!(:user_id).and_return("1")
    @title_review.stub!(:body).and_return("MyText")

    assigns[:title_review] = @title_review
  end

  it "should render attributes in <p>" do
    render "/title_reviews/show.html.erb"
    response.should have_text(/MyText/)
  end
end

