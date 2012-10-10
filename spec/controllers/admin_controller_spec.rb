require 'spec_helper'

describe AdminController do

  describe "GET 'nav'" do
    it "returns http success" do
      get 'nav'
      response.should be_success
    end
  end

end
