require 'spec_helper'

describe BuyerController do

  describe "GET 'entries'" do
    it "returns http success" do
      get 'entries'
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      get 'show'
      response.should be_success
    end
  end

  describe "GET 'print'" do
    it "returns http success" do
      get 'print'
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
