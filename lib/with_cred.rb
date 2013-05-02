require "with_cred/version"

class CredentialsNotFoundError < StandardError ; end

module WithCred
  def self.entials_for(file)

    # This method ignores the block if the credentials are required, and we are not supposed to need them.
    # Passes the credentials into the block as read from the credentials YAML file at "#{Rails.root}/credentials/#{file}.yaml"

    if (allowed = (Rails.application.config.credentials_mode == "production"))

      credentials = nil

      begin
        credentials = YAML::load_file("#{Rails.root}/credentials/#{file.to_s}.yaml")
      rescue
        raise CredentialsNotFoundError
      end

      yield credentials
    end

    return allowed

  end
end

