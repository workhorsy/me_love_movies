require File.dirname(__FILE__) + '/../../spec_helper'

describe "/title_ratings/show.html.erb" do
  include TitleRatingsHelper
  
  before(:each) do
    @title_rating = mock_model(TitleRating)
    @title_rating.stub!(:action).and_return("1")
    @title_rating.stub!(:comedy).and_return("1")
    @title_rating.stub!(:drama).and_return("1")
    @title_rating.stub!(:scifi).and_return("1")
    @title_rating.stub!(:romance).and_return("1")
    @title_rating.stub!(:musical).and_return("1")
    @title_rating.stub!(:kids).and_return("1")
    @title_rating.stub!(:adventure).and_return("1")
    @title_rating.stub!(:mystery).and_return("1")
    @title_rating.stub!(:suspense).and_return("1")
    @title_rating.stub!(:horror).and_return("1")
    @title_rating.stub!(:fantasy).and_return("1")
    @title_rating.stub!(:tv).and_return("1")
    @title_rating.stub!(:war).and_return("1")
    @title_rating.stub!(:western).and_return("1")
    @title_rating.stub!(:sports).and_return("1")
    @title_rating.stub!(:premise).and_return("1")
    @title_rating.stub!(:plot).and_return("1")
    @title_rating.stub!(:score).and_return("1")
    @title_rating.stub!(:acting).and_return("1")
    @title_rating.stub!(:special_effects).and_return("1")
    @title_rating.stub!(:pace).and_return("1")
    @title_rating.stub!(:character_development).and_return("1")
    @title_rating.stub!(:cinematography).and_return("1")

    assigns[:title_rating] = @title_rating
  end

  it "should render attributes in <p>" do
    render "/title_ratings/show.html.erb"
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
  end
end

