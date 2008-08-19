require File.dirname(__FILE__) + '/../../spec_helper'

describe "/title_reviews/index.html.erb" do
  include TitleReviewsHelper
  
  before(:each) do
    title_review_98 = mock_model(TitleReview)
    title_review_98.should_receive(:user_id).and_return("1")
    title_review_98.should_receive(:body).and_return("MyText")
    title_review_99 = mock_model(TitleReview)
    title_review_99.should_receive(:user_id).and_return("1")
    title_review_99.should_receive(:body).and_return("MyText")

    assigns[:title_reviews] = [title_review_98, title_review_99]
  end

  it "should render list of title_reviews" do
    render "/title_reviews/index.html.erb"
    response.should have_tag("tr>td", "MyText", 2)
  end
end

