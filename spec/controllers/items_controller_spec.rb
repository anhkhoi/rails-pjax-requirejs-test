require "spec_helper"

describe ItemsController do

  let(:item) { FactoryGirl.build_stubbed(:item) }
  
  before(:each) do
    subject.stub(:load_item).and_return(item)
  end
  
  describe "#index" do
    before(:each) do
      subject.should_receive(:load_items).and_return([item])
      get :index
    end

    it "should respond with success" do
      expect(response.status).to eq 200
    end

    it "should assign @items" do
      expect(assigns(:items)).to eq([item])
    end
  end

  describe "#new" do
    before(:each) { get :new }
  
    it "should respond with success" do
      expect(response.status).to eq 200
    end
  
    it "should assign @item" do
      expect(assigns(:item)).to be_kind_of(Item)
    end
  end
  
  describe "#create" do
    before(:each) do
      Item.any_instance.should_receive(:save).and_return(true)
      post :create, item: {}
    end
  
    it "should respond with success" do
      expect(response.status).to eq 302
    end
  end
    
  describe "#show" do
    before(:each) { get :show, id: "123" }
  
    it "should respond with success" do
      expect(response.status).to eq 200
    end
  
    it "should assign @item" do
      expect(assigns(:item)).to eq(item)
    end
    
    it "should be cached" do
      expect(response.headers).to have_key("ETag")
    end
  end
  
  describe "#edit" do
    before(:each) { get :edit, id: "123" }
  
    it "should respond with success" do
      expect(response.status).to eq 200
    end
  
    it "should assign @item" do
      expect(assigns(:item)).to eq(item)
    end
  end
  
  describe "#update" do
    before(:each) do
      item.should_receive(:update_attributes).and_return(true)
      put :update, id: "123", item: {}
    end
  
    it "should respond with redirect" do
      expect(response.status).to eq 302
    end
  end
  
  describe "#destroy" do
    before(:each) do
      item.should_receive(:destroy).and_return(true)
      delete :destroy, id: "123"
    end
  
    it "should respond with redirect" do
      expect(response.status).to eq 302
    end
  end

end
