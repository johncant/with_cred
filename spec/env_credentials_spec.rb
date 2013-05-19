require 'spec_helper'

describe WithCred do
  context 'from environment variables' do
    let(:password) { 'secret' }
    let(:credentials) {
      {
        :development => {
          :merchant_account => {
            :api_key => "secret"
          }
        },
        :_all => {
          :gateway => {
            :name => 'swipe'
          }
        }
      }.to_yaml
    }
    let(:encrypted_credentials) {
      Base64.encode64(Encryptor.encrypt(credentials, :key => password, :algorithm => 'aes-256-cbc'))
    }

    before do
      ENV['ENCRYPTED_CREDENTIALS'] = encrypted_credentials
      ENV['PASSWORD'] = password

      WithCred.add_from_environment_vars
    end

    it "decrypts the credentials" do
      WithCred.entials_for(:merchant_account) do |c|
        c[:api_key].should == "secret"
      end
    end

    it "allows credentials for all environments" do
      WithCred.entials_for(:gateway) do |c|
        c[:name].should == "swipe"
      end
    end

    after do
      ENV['ENCRYPTED_CREDENTIALS'] = nil
      ENV['PASSWORD'] = nil
    end
  end
end
