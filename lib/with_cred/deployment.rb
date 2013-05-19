module WithCred
  module Deployment

    class << self
      attr_accessor :password, :encrypted_credentials, :credentials_mode
    end

    @@credentials_mode = :production

    def assert_valid_credentials
      credentials = WithCred.all(@@credentials_mode)

      begin
        decrypted_credentials = YAML::load(Encryptor.decrypt(encrypted_credentials, :key => password, :algorithm => 'aes-256-cbc'))
      rescue Yaml::Exception
        raise InvalidCredentialsError
      end

      unless decrypted_credentials[@@credentials_mode] == credentials
        raise InvalidCredentialsError
      end
    end
  end
end
