require File.dirname(__FILE__) + '/../spec_helper'

describe TitleRatingsController do
  describe "route generation" do

    it "should map { :controller => 'title_ratings', :action => 'index' } to /title_ratings" do
      route_for(:controller => "title_ratings", :action => "index").should == "/title_ratings"
    end
  
    it "should map { :controller => 'title_ratings', :action => 'new' } to /title_ratings/new" do
      route_for(:controller => "title_ratings", :action => "new").should == "/title_ratings/new"
    end
  
    it "should map { :controller => 'title_ratings', :action => 'show', :id => 1 } to /title_ratings/1" do
      route_for(:controller => "title_ratings", :action => "show", :id => 1).should == "/title_ratings/1"
    end
  
    it "should map { :controller => 'title_ratings', :action => 'edit', :id => 1 } to /title_ratings/1/edit" do
      route_for(:controller => "title_ratings", :action => "edit", :id => 1).should == "/title_ratings/1/edit"
    end
  
    it "should map { :controller => 'title_ratings', :action => 'update', :id => 1} to /title_ratings/1" do
      route_for(:controller => "title_ratings", :action => "update", :id => 1).should == "/title_ratings/1"
    end
  
    it "should map { :controller => 'title_ratings', :action => 'destroy', :id => 1} to /title_ratings/1" do
      route_for(:controller => "title_ratings", :action => "destroy", :id => 1).should == "/title_ratings/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'title_ratings', action => 'index' } from GET /title_ratings" do
      params_from(:get, "/title_ratings").should == {:controller => "title_ratings", :action => "index"}
    end
  
    it "should generate params { :controller => 'title_ratings', action => 'new' } from GET /title_ratings/new" do
      params_from(:get, "/title_ratings/new").should == {:controller => "title_ratings", :action => "new"}
    end
  
    it "should generate params { :controller => 'title_ratings', action => 'create' } from POST /title_ratings" do
      params_from(:post, "/title_ratings").should == {:controller => "title_ratings", :action => "create"}
    end
  
    it "should generate params { :controller => 'title_ratings', action => 'show', id => '1' } from GET /title_ratings/1" do
      params_from(:get, "/title_ratings/1").should == {:controller => "title_ratings", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'title_ratings', action => 'edit', id => '1' } from GET /title_ratings/1;edit" do
      params_from(:get, "/title_ratings/1/edit").should == {:controller => "title_ratings", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'title_ratings', action => 'update', id => '1' } from PUT /title_ratings/1" do
      params_from(:put, "/title_ratings/1").should == {:controller => "title_ratings", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'title_ratings', action => 'destroy', id => '1' } from DELETE /title_ratings/1" do
      params_from(:delete, "/title_ratings/1").should == {:controller => "title_ratings", :action => "destroy", :id => "1"}
    end
  end
end