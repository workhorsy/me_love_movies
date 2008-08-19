require File.dirname(__FILE__) + '/../spec_helper'

describe TitleReviewsController do
  describe "handling GET /title_reviews" do

    before(:each) do
      @title_review = mock_model(TitleReview)
      TitleReview.stub!(:find).and_return([@title_review])
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
  
    it "should find all title_reviews" do
      TitleReview.should_receive(:find).with(:all).and_return([@title_review])
      do_get
    end
  
    it "should assign the found title_reviews for the view" do
      do_get
      assigns[:title_reviews].should == [@title_review]
    end
  end

  describe "handling GET /title_reviews.xml" do

    before(:each) do
      @title_review = mock_model(TitleReview, :to_xml => "XML")
      TitleReview.stub!(:find).and_return(@title_review)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all title_reviews" do
      TitleReview.should_receive(:find).with(:all).and_return([@title_review])
      do_get
    end
  
    it "should render the found title_reviews as xml" do
      @title_review.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /title_reviews/1" do

    before(:each) do
      @title_review = mock_model(TitleReview)
      TitleReview.stub!(:find).and_return(@title_review)
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
  
    it "should find the title_review requested" do
      TitleReview.should_receive(:find).with("1").and_return(@title_review)
      do_get
    end
  
    it "should assign the found title_review for the view" do
      do_get
      assigns[:title_review].should equal(@title_review)
    end
  end

  describe "handling GET /title_reviews/1.xml" do

    before(:each) do
      @title_review = mock_model(TitleReview, :to_xml => "XML")
      TitleReview.stub!(:find).and_return(@title_review)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the title_review requested" do
      TitleReview.should_receive(:find).with("1").and_return(@title_review)
      do_get
    end
  
    it "should render the found title_review as xml" do
      @title_review.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /title_reviews/new" do

    before(:each) do
      @title_review = mock_model(TitleReview)
      TitleReview.stub!(:new).and_return(@title_review)
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
  
    it "should create an new title_review" do
      TitleReview.should_receive(:new).and_return(@title_review)
      do_get
    end
  
    it "should not save the new title_review" do
      @title_review.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new title_review for the view" do
      do_get
      assigns[:title_review].should equal(@title_review)
    end
  end

  describe "handling GET /title_reviews/1/edit" do

    before(:each) do
      @title_review = mock_model(TitleReview)
      TitleReview.stub!(:find).and_return(@title_review)
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
  
    it "should find the title_review requested" do
      TitleReview.should_receive(:find).and_return(@title_review)
      do_get
    end
  
    it "should assign the found TitleReview for the view" do
      do_get
      assigns[:title_review].should equal(@title_review)
    end
  end

  describe "handling POST /title_reviews" do

    before(:each) do
      @title_review = mock_model(TitleReview, :to_param => "1")
      TitleReview.stub!(:new).and_return(@title_review)
    end
    
    describe "with successful save" do
  
      def do_post
        @title_review.should_receive(:save).and_return(true)
        post :create, :title_review => {}
      end
  
      it "should create a new title_review" do
        TitleReview.should_receive(:new).with({}).and_return(@title_review)
        do_post
      end

      it "should redirect to the new title_review" do
        do_post
        response.should redirect_to(title_review_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @title_review.should_receive(:save).and_return(false)
        post :create, :title_review => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /title_reviews/1" do

    before(:each) do
      @title_review = mock_model(TitleReview, :to_param => "1")
      TitleReview.stub!(:find).and_return(@title_review)
    end
    
    describe "with successful update" do

      def do_put
        @title_review.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the title_review requested" do
        TitleReview.should_receive(:find).with("1").and_return(@title_review)
        do_put
      end

      it "should update the found title_review" do
        do_put
        assigns(:title_review).should equal(@title_review)
      end

      it "should assign the found title_review for the view" do
        do_put
        assigns(:title_review).should equal(@title_review)
      end

      it "should redirect to the title_review" do
        do_put
        response.should redirect_to(title_review_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @title_review.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /title_reviews/1" do

    before(:each) do
      @title_review = mock_model(TitleReview, :destroy => true)
      TitleReview.stub!(:find).and_return(@title_review)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the title_review requested" do
      TitleReview.should_receive(:find).with("1").and_return(@title_review)
      do_delete
    end
  
    it "should call destroy on the found title_review" do
      @title_review.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the title_reviews list" do
      do_delete
      response.should redirect_to(title_reviews_url)
    end
  end
end