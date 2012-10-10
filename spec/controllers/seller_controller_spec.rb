require 'spec_helper'

describe SellerController do

  describe "GET 'entries'" do
    it "returns http success" do
      get 'entries'
      response.should be_success
    end
  end

  describe "GET 'worksheet'" do
    it "returns http success" do
      get 'worksheet'
      response.should be_success
    end
  end

  describe "GET 'bids'" do
    it "returns http success" do
      get 'bids'
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      get 'show'
      response.should be_success
    end
  end

  describe "GET 'orders'" do
    it "returns http success" do
      get 'orders'
      response.should be_success
    end
  end

  describe "GET 'fees'" do
    it "returns http success" do
      get 'fees'
      response.should be_success
    end
  end

end
