require File.dirname(__FILE__) + '/../spec_helper'

describe TitleRatingsController do
  describe "handling GET /title_ratings" do

    before(:each) do
      @title_rating = mock_model(TitleRating)
      TitleRating.stub!(:find).and_return([@title_rating])
    end
  
    def do_get
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
  
    it "should find all title_ratings" do
      TitleRating.should_receive(:find).with(:all).and_return([@title_rating])
      do_get
    end
  
    it "should assign the found title_ratings for the view" do
      do_get
      assigns[:title_ratings].should == [@title_rating]
    end
  end

  describe "handling GET /title_ratings.xml" do

    before(:each) do
      @title_rating = mock_model(TitleRating, :to_xml => "XML")
      TitleRating.stub!(:find).and_return(@title_rating)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all title_ratings" do
      TitleRating.should_receive(:find).with(:all).and_return([@title_rating])
      do_get
    end
  
    it "should render the found title_ratings as xml" do
      @title_rating.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /title_ratings/1" do

    before(:each) do
      @title_rating = mock_model(TitleRating)
      TitleRating.stub!(:find).and_return(@title_rating)
    end
  
    def do_get
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  
    it "should find the title_rating requested" do
      TitleRating.should_receive(:find).with("1").and_return(@title_rating)
      do_get
    end
  
    it "should assign the found title_rating for the view" do
      do_get
      assigns[:title_rating].should equal(@title_rating)
    end
  end

  describe "handling GET /title_ratings/1.xml" do

    before(:each) do
      @title_rating = mock_model(TitleRating, :to_xml => "XML")
      TitleRating.stub!(:find).and_return(@title_rating)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the title_rating requested" do
      TitleRating.should_receive(:find).with("1").and_return(@title_rating)
      do_get
    end
  
    it "should render the found title_rating as xml" do
      @title_rating.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /title_ratings/new" do

    before(:each) do
      @title_rating = mock_model(TitleRating)
      TitleRating.stub!(:new).and_return(@title_rating)
    end
  
    def do_get
      get :new
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render new template" do
      do_get
      response.should render_template('new')
    end
  
    it "should create an new title_rating" do
      TitleRating.should_receive(:new).and_return(@title_rating)
      do_get
    end
  
    it "should not save the new title_rating" do
      @title_rating.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new title_rating for the view" do
      do_get
      assigns[:title_rating].should equal(@title_rating)
    end
  end

  describe "handling GET /title_ratings/1/edit" do

    before(:each) do
      @title_rating = mock_model(TitleRating)
      TitleRating.stub!(:find).and_return(@title_rating)
    end
  
    def do_get
      get :edit, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the title_rating requested" do
      TitleRating.should_receive(:find).and_return(@title_rating)
      do_get
    end
  
    it "should assign the found TitleRating for the view" do
      do_get
      assigns[:title_rating].should equal(@title_rating)
    end
  end

  describe "handling POST /title_ratings" do

    before(:each) do
      @title_rating = mock_model(TitleRating, :to_param => "1")
      TitleRating.stub!(:new).and_return(@title_rating)
    end
    
    describe "with successful save" do
  
      def do_post
        @title_rating.should_receive(:save).and_return(true)
        post :create, :title_rating => {}
      end
  
      it "should create a new title_rating" do
        TitleRating.should_receive(:new).with({}).and_return(@title_rating)
        do_post
      end

      it "should redirect to the new title_rating" do
        do_post
        response.should redirect_to(title_rating_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @title_rating.should_receive(:save).and_return(false)
        post :create, :title_rating => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /title_ratings/1" do

    before(:each) do
      @title_rating = mock_model(TitleRating, :to_param => "1")
      TitleRating.stub!(:find).and_return(@title_rating)
    end
    
    describe "with successful update" do

      def do_put
        @title_rating.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the title_rating requested" do
        TitleRating.should_receive(:find).with("1").and_return(@title_rating)
        do_put
      end

      it "should update the found title_rating" do
        do_put
        assigns(:title_rating).should equal(@title_rating)
      end

      it "should assign the found title_rating for the view" do
        do_put
        assigns(:title_rating).should equal(@title_rating)
      end

      it "should redirect to the title_rating" do
        do_put
        response.should redirect_to(title_rating_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @title_rating.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /title_ratings/1" do

    before(:each) do
      @title_rating = mock_model(TitleRating, :destroy => true)
      TitleRating.stub!(:find).and_return(@title_rating)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the title_rating requested" do
      TitleRating.should_receive(:find).with("1").and_return(@title_rating)
      do_delete
    end
  
    it "should call destroy on the found title_rating" do
      @title_rating.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the title_ratings list" do
      do_delete
      response.should redirect_to(title_ratings_url)
    end
  end
end