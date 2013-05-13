require "with_cred/version"
require "with_cred/railtie" if defined?(::Rails)

class CredentialsNotFoundError < StandardError ; end

module WithCred

  def self.credentials_dir
    @@credentials_dir
  end
  def self.credentials_dir=(foo)
    @@credentials_dir = foo
  end

  if defined?(::Rails)
    def self.credentials_mode
      ::Rails.application.config.credentials_mode
    end

    @@credentials_dir = ::Rails.root
  else
    def self.credentials_mode
      "production"
    end

    @@credentials_dir = ENV["PWD"]
  end

  def self.entials_for(file)

    # This method ignores the block if the credentials are required, and we are not supposed to need them.
    # Passes the credentials into the block as read from the credentials YAML file at "#{::Rails.root}/credentials/#{file}.yaml"

    if (allowed = (self.credentials_mode == "production"))

      credentials = nil

      begin
        credentials = YAML::load_file(File.join(self.credentials_dir, "/credentials/#{file.to_s}.yaml"))
      rescue
        raise CredentialsNotFoundError
      end

      yield credentials
    end

    return allowed

  end
end

