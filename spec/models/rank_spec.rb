require File.dirname(__FILE__) + '/../spec_helper'

describe Rank do
  it "should be valid" do
    Rank.new.should be_valid
  end
end
