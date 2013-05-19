require 'spec_helper'


describe WithCred do

  context "in a rails app" do
    context "config" do
      it "configures based on credentials_mode" do
        WithCred.credentials_mode.should == "development"
      end
    end
  end


end
