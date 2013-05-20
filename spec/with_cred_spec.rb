require 'spec_helper'


describe WithCred do

  context "in a rails app" do
    context "config" do
      let(:config) {
        config = WithCred::ApplicationConfiguration.new
      }
      it "configures based on credentials_mode" do
        config.credentials_mode.should == "development"
        config.credentials_dir.should == File.join(Rails.root, "credentials")
      end
    end
  end


end
