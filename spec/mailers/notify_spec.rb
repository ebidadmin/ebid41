require "spec_helper"

describe Notify do
  describe "online_entry" do
    let(:mail) { Notify.online_entry }

    it "renders the headers" do
      mail.subject.should eq("Online entry")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
