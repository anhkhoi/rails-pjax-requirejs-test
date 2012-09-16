require "spec_helper"

describe GuidesController do

  let(:item) { FactoryGirl.build_stubbed(:item) }
  let(:guide) { FactoryGirl.build_stubbed(:guide) }
  
  before(:each) do
    subject.stub(:find_item).and_return(item)
    subject.stub(:find_guide).and_return(guide)
  end

  describe "#new" do
    before(:each) { get :new, item_id: "123" }

    it "should respond with success" do
      expect(response.status).to eq 200
    end
    
    it "should assign @item" do
      expect(assigns(:item)).to eq(item)
    end

    it "should assign @guide" do
      expect(assigns(:guide)).to be_kind_of(Guide)
    end
  end

  describe "#create" do
    before(:each) do
      Guide.any_instance.should_receive(:save).and_return(true)
      post :create, item_id: "123", guide: {}
    end

    it "should respond with success" do
      expect(response.status).to eq 302
    end
  end

  describe "#show" do
    before(:each) { get :show, item_id: "123", id: "456" }

    it "should respond with success" do
      expect(response.status).to eq 200
    end
    
    it "should assign @item" do
      expect(assigns(:item)).to eq(item)
    end

    it "should assign @guide" do
      expect(assigns(:guide)).to eq(guide)
    end

    it "should be cached" do
      expect(response.headers).to have_key("ETag")
    end
  end

  describe "#edit" do
    before(:each) { get :edit, item_id: "123", id: "456" }

    it "should respond with success" do
      expect(response.status).to eq 200
    end

    it "should assign @item" do
      expect(assigns(:item)).to eq(item)
    end
    
    it "should assign @guide" do
      expect(assigns(:guide)).to eq(guide)
    end
  end

  describe "#update" do
    before(:each) do
      guide.should_receive(:update_attributes).and_return(true)
      put :update, item_id: "123", id: "456", guide: {}
    end

    it "should respond with redirect" do
      expect(response.status).to eq 302
    end
  end

  describe "#destroy" do
    before(:each) do
      guide.should_receive(:destroy).and_return(true)
      delete :destroy, item_id: "123", id: "456"
    end

    it "should respond with redirect" do
      expect(response.status).to eq 302
    end
  end

end
