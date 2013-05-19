require "with_cred/version"
require "with_cred/deployment"
require "with_cred/railtie" if defined?(::Rails)
require "with_cred/capistrano" if defined?(::Capistrano)
require "base64"
require "encryptor"

class CredentialsNotFoundError < StandardError ; end

module WithCred

  class InvalidCredentialsError < StandardError ; end

  # Config that we inherit from rails, and its replacement if we don't have Rails
  def self.credentials_dir=(foo)
    @@credentials_dir = foo
  end

  if defined?(::Rails)
    def self.credentials_mode
      if ::Rails.application.config.respond_to?(:credentials_mode)
        ::Rails.application.config.credentials_mode
      end
    end

    def self.credentials_dir
      @@credentials_dir ||= File.join(::Rails.root, 'credentials')
    end
  else
    def self.credentials_mode
      "production"
    end

    def self.credentials_dir
      @@credentials_dir ||= File.join(ENV["PWD"], 'credentials')
    end
  end

  class << self
    attr_accessor :credentials_hash
  end
  self.credentials_hash = {}

  def self.encrypted
    password = ENV['PASSWORD']
    Base64.encode64(Encryptor.encrypt(self.credentials_hash.to_yaml, :key => password, :algorithm => 'aes-256-cbc'))
  end

  def self.add_from_environment_vars

    password = ENV['PASSWORD']
    encrypted = ENV['ENCRYPTED_CREDENTIALS']

    if password && encrypted
      yaml = Encryptor.decrypt(Base64.decode64(encrypted), :key => password, :algorithm => 'aes-256-cbc')
      self.credentials_hash = self.credentials_hash.merge(YAML::load(yaml))
    end
  end

  def self.add_from_files
    all_credentials_files = Dir[File.join(self.credentials_dir, "**", "*.yaml")]

    all_credentials_files.each do |path|

      hash_path =
        path.gsub(/\.[^\.]*$/, '').
        gsub(/^#{self.credentials_dir}/, '').
        split('/').
        reject{|tok| tok.length == 0}

      if File.join(File.dirname(path), "") == File.join(self.credentials_dir, "")
        hash_path.unshift(:_all)
      end

      credentials = YAML::load_file(path)

      self.add_credentials(hash_path, credentials)
    end
  end

  def self.add_credentials(path = [], leaf = {})

    key = path.pop

    twig = path.inject(self.credentials_hash) do |hash, key|
      hash[key.to_sym] ||= {}
    end

    twig[key.to_sym] = leaf

  end

  def self.check!
    unless Digest::SHA256.hexdigest(Base64.decode64(self.encrypted)) == File.read(File.join(self.credentials_dir, 'credentials.lock'))
      raise InvalidCredentialsError.new('Fingerprint does not match')
    end
  end

  def self.lock
    File.open(File.join(self.credentials_dir, 'credentials.lock'), 'w') do |f|
      f.write Digest::SHA256.hexdigest(Base64.decode64(self.encrypted))
    end
  end

  def self.entials_for(*hash_path)

    # This method ignores the block if the credentials are required, and we are not supposed to need them.
    # Passes the credentials into the block as read from the credentials YAML file at "#{::Rails.root}/credentials/#{file}.yaml"

    our_mode_credentials = self.credentials_hash[self.credentials_mode.to_sym] || {}
    all_mode_credentials = self.credentials_hash[:_all] || {}
    hash_place = all_mode_credentials.merge(our_mode_credentials)

    # Delve
    hash_path.each do |key|
      key = key.to_sym
      hash_place[key] ||= {}
      hash_place = hash_place[key]
    end

    raise(CredentialsNotFoundError) unless hash_place
    yield hash_place

  end
end

