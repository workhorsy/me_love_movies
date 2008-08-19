require File.dirname(__FILE__) + '/../../spec_helper'

describe "/title_reviews/edit.html.erb" do
  include TitleReviewsHelper
  
  before do
    @title_review = mock_model(TitleReview)
    @title_review.stub!(:user_id).and_return("1")
    @title_review.stub!(:body).and_return("MyText")
    assigns[:title_review] = @title_review
  end

  it "should render edit form" do
    render "/title_reviews/edit.html.erb"
    
    response.should have_tag("form[action=#{title_review_path(@title_review)}][method=post]") do
      with_tag('textarea#title_review_body[name=?]', "title_review[body]")
    end
  end
end


