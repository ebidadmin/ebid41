require File.dirname(__FILE__) + '/../spec_helper'

describe VarItem do
  it "should be valid" do
    VarItem.new.should be_valid
  end
end
