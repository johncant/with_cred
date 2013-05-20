require "with_cred/version"
require "with_cred/deployment"
require "with_cred/railtie" if defined?(::Rails)
#require "with_cred/capistrano" if defined?(::Capistrano)
require "base64"
require "encryptor"

class CredentialsNotFoundError < StandardError ; end

module WithCred

  class InvalidCredentialsError < StandardError ; end

  class Configuration
    attr_accessor :credentials_dir, :credententials_mode, :credentials_hash, :password

    def initialize
      @algorithm = 'aes-256-cbc'
      @credentials_hash = {}
    end

    def add_from_encrypted(ciphertext)
      if ciphertext
        encrypted_binary = Base64.urlsafe_decode64(ciphertext)
        decrypted_yaml = Encryptor.decrypt(encrypted_binary, :key => @password, :algorithm => @algorithm)
        decrypted_hash = YAML::load(decrypted_yaml)
        @credentials_hash.merge!(decrypted_hash)
      end
    end

    def encrypted
      Base64.urlsafe_encode64(encrypted_binary)
    end

    def encrypted_binary
      Encryptor.encrypt(@credentials_hash.to_yaml, :key => @password, :algorithm => @algorithm)
    end

    def check!(fp)
      check(fp) || raise(InvalidCredentialsError.new("The fingerprints do not match"))
    end

    def check(fp)
      fingerprint == fp
    end

    def fingerprint
      Digest::SHA256.hexdigest(Base64.urlsafe_decode64(encrypted))
    end

    def add_credentials(path = [], leaf = {})

      key = path.pop

      twig = path.inject(@credentials_hash) do |hash, key|
        hash[key.to_sym] ||= {}
      end

      twig[key.to_sym] = leaf

    end

    def credentials_for_mode(mode)
      our_mode_credentials = @credentials_hash[mode.to_sym] || {}
      all_mode_credentials = @credentials_hash[:_all] || {}
      all_mode_credentials.merge(our_mode_credentials)
    end

  end

  class ApplicationConfiguration < Configuration

    attr_accessor :credentials_dir, :credentials_mode

    def initialize

      super
      if defined?(::Rails)
        @src_root = ::Rails.root
      else
        @src_root = ENV['PWD']
      end

      if defined?(::Rails) && ::Rails.application.config.respond_to?(:credentials_mode)
        @credentials_mode = ::Rails.application.config.credentials_mode
      else
        @credentials_mode = "production"
      end

      @credentials_dir = File.join(@src_root, 'credentials')

      self.password = ENV['PASSWORD']
      self.add_from_encrypted(ENV['ENCRYPTED_CREDENTIALS'])
      add_from_files

    end

    def add_from_files
      all_credentials_files = Dir[File.join(@credentials_dir, "**", "*.yaml")]

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

        add_credentials(hash_path, credentials)
      end
    end

    def check!(fp = nil)
      super(fp || File.read(lock_file_name))
    end

    def lock
      File.open(lock_file_name, 'w') do |f|
        f.write fingerprint
      end
    end

    def credentials_for_current_mode
      credentials_for_mode(@credentials_mode)
    end

    private
    def lock_file_name
      File.join(@src_root, 'credentials.lock')
    end

  end

  class << self
    attr_accessor :application_config

    [:encrypted, :check!, :lock].each do |m|
      define_method m do |*args, &block|
        self.application_config.public_send(m, *args, &block)
      end
    end
  end

  def self.configure
    self.application_config ||= ApplicationConfiguration.new
    yield application_config if block_given?
  end

  def self.deconfigure
    self.application_config = nil
  end

  def self.entials_for(*hash_path)

    hash_place = application_config.credentials_for_current_mode

    # Delve
    hash_path.each do |key|
      key = key.to_sym
      hash_place[key] ||= {}
      hash_place = hash_place[key]
    end

    yield hash_place

  end

end

