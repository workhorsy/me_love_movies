require File.dirname(__FILE__) + '/../../spec_helper'

describe "/title_reviews/new.html.erb" do
  include TitleReviewsHelper
  
  before(:each) do
    @title_review = mock_model(TitleReview)
    @title_review.stub!(:new_record?).and_return(true)
    @title_review.stub!(:user_id).and_return("1")
    @title_review.stub!(:body).and_return("MyText")
    assigns[:title_review] = @title_review
  end

  it "should render new form" do
    render "/title_reviews/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", title_reviews_path) do
      with_tag("textarea#title_review_body[name=?]", "title_review[body]")
    end
  end
end


