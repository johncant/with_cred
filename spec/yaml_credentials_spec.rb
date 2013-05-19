require 'spec_helper'


describe WithCred do

  context "in a rails app" do
    before do
      WithCred.add_from_files
    end

    context "credentials from yaml files" do
      it "loads credentials from a tree of nested files" do
        WithCred.entials_for(:twitter) do |c|
          c[:api][:secret].should == "some_token"
        end
      end
    end

    context "retrieving credentials" do
      it "loads credentials for the correct environment" do
        WithCred.entials_for(:twitter) do |c|
          c.should_not be_empty
        end
      end

      it "ignores credentials for other environments" do
        Rails.application.config.stub(:credentials_mode).and_return("production")
        WithCred.entials_for(:twitter) do |c|
          c.should be_empty
        end
      end

      it "loads root credentials for all environments" do
        WithCred.entials_for(:github) do |c|
          c[:password].should == "developer"
        end
      end
    end

  end
end
