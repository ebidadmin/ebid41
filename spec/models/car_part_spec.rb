require File.dirname(__FILE__) + '/../spec_helper'

describe CarPart do
  it "should be valid" do
    CarPart.new.should be_valid
  end
end
