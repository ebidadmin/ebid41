require File.dirname(__FILE__) + '/../spec_helper'

describe CarVariant do
  it "should be valid" do
    CarVariant.new.should be_valid
  end
end
