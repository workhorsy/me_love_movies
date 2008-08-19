require File.dirname(__FILE__) + '/../spec_helper'

describe TitleReviewsController do
  describe "route generation" do

    it "should map { :controller => 'title_reviews', :action => 'index' } to /title_reviews" do
      route_for(:controller => "title_reviews", :action => "index").should == "/title_reviews"
    end
  
    it "should map { :controller => 'title_reviews', :action => 'new' } to /title_reviews/new" do
      route_for(:controller => "title_reviews", :action => "new").should == "/title_reviews/new"
    end
  
    it "should map { :controller => 'title_reviews', :action => 'show', :id => 1 } to /title_reviews/1" do
      route_for(:controller => "title_reviews", :action => "show", :id => 1).should == "/title_reviews/1"
    end
  
    it "should map { :controller => 'title_reviews', :action => 'edit', :id => 1 } to /title_reviews/1/edit" do
      route_for(:controller => "title_reviews", :action => "edit", :id => 1).should == "/title_reviews/1/edit"
    end
  
    it "should map { :controller => 'title_reviews', :action => 'update', :id => 1} to /title_reviews/1" do
      route_for(:controller => "title_reviews", :action => "update", :id => 1).should == "/title_reviews/1"
    end
  
    it "should map { :controller => 'title_reviews', :action => 'destroy', :id => 1} to /title_reviews/1" do
      route_for(:controller => "title_reviews", :action => "destroy", :id => 1).should == "/title_reviews/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'title_reviews', action => 'index' } from GET /title_reviews" do
      params_from(:get, "/title_reviews").should == {:controller => "title_reviews", :action => "index"}
    end
  
    it "should generate params { :controller => 'title_reviews', action => 'new' } from GET /title_reviews/new" do
      params_from(:get, "/title_reviews/new").should == {:controller => "title_reviews", :action => "new"}
    end
  
    it "should generate params { :controller => 'title_reviews', action => 'create' } from POST /title_reviews" do
      params_from(:post, "/title_reviews").should == {:controller => "title_reviews", :action => "create"}
    end
  
    it "should generate params { :controller => 'title_reviews', action => 'show', id => '1' } from GET /title_reviews/1" do
      params_from(:get, "/title_reviews/1").should == {:controller => "title_reviews", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'title_reviews', action => 'edit', id => '1' } from GET /title_reviews/1;edit" do
      params_from(:get, "/title_reviews/1/edit").should == {:controller => "title_reviews", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'title_reviews', action => 'update', id => '1' } from PUT /title_reviews/1" do
      params_from(:put, "/title_reviews/1").should == {:controller => "title_reviews", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'title_reviews', action => 'destroy', id => '1' } from DELETE /title_reviews/1" do
      params_from(:delete, "/title_reviews/1").should == {:controller => "title_reviews", :action => "destroy", :id => "1"}
    end
  end
end