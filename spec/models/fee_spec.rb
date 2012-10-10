require File.dirname(__FILE__) + '/../spec_helper'

describe Fee do
  it "should be valid" do
    Fee.new.should be_valid
  end
end
