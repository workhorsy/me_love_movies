require File.dirname(__FILE__) + '/../../spec_helper'

describe "/title_ratings/edit.html.erb" do
  include TitleRatingsHelper
  
  before do
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

  it "should render edit form" do
    render "/title_ratings/edit.html.erb"
    
    response.should have_tag("form[action=#{title_rating_path(@title_rating)}][method=post]") do
      with_tag('input#title_rating_action[name=?]', "title_rating[action]")
      with_tag('input#title_rating_comedy[name=?]', "title_rating[comedy]")
      with_tag('input#title_rating_drama[name=?]', "title_rating[drama]")
      with_tag('input#title_rating_scifi[name=?]', "title_rating[scifi]")
      with_tag('input#title_rating_romance[name=?]', "title_rating[romance]")
      with_tag('input#title_rating_musical[name=?]', "title_rating[musical]")
      with_tag('input#title_rating_kids[name=?]', "title_rating[kids]")
      with_tag('input#title_rating_adventure[name=?]', "title_rating[adventure]")
      with_tag('input#title_rating_mystery[name=?]', "title_rating[mystery]")
      with_tag('input#title_rating_suspense[name=?]', "title_rating[suspense]")
      with_tag('input#title_rating_horror[name=?]', "title_rating[horror]")
      with_tag('input#title_rating_fantasy[name=?]', "title_rating[fantasy]")
      with_tag('input#title_rating_tv[name=?]', "title_rating[tv]")
      with_tag('input#title_rating_war[name=?]', "title_rating[war]")
      with_tag('input#title_rating_western[name=?]', "title_rating[western]")
      with_tag('input#title_rating_sports[name=?]', "title_rating[sports]")
      with_tag('input#title_rating_premise[name=?]', "title_rating[premise]")
      with_tag('input#title_rating_plot[name=?]', "title_rating[plot]")
      with_tag('input#title_rating_score[name=?]', "title_rating[score]")
      with_tag('input#title_rating_acting[name=?]', "title_rating[acting]")
      with_tag('input#title_rating_special_effects[name=?]', "title_rating[special_effects]")
      with_tag('input#title_rating_pace[name=?]', "title_rating[pace]")
      with_tag('input#title_rating_character_development[name=?]', "title_rating[character_development]")
      with_tag('input#title_rating_cinematography[name=?]', "title_rating[cinematography]")
    end
  end
end


