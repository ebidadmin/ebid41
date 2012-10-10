require File.dirname(__FILE__) + '/../spec_helper'

describe CarBrand do
  it "should be valid" do
    CarBrand.new.should be_valid
  end
end
