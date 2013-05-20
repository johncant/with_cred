namespace :credentials do

  desc "Decrypt the set of credentials"
  task :decrypt, :passphrase_file do |t, args|
    passphrase_options = "--passphrase-file #{args[:passphrase_file]}" unless args[:passphrase_file].blank?
    puts args.inspect

    `mkdir credentials/` unless File.exists?("credentials")
    `gpg --yes #{passphrase_options} --no-use-agent --no-tty -o credentials/credentials.tar.gz --decrypt credentials.tar.gz.gpg`
    `tar -C credentials -xf credentials/credentials.tar.gz`

  end

  desc "Encrypt the credentials"
  task :encrypt, :passphrase_file do |t, args|
    passphrase_options = "--passphrase-file #{args[:passphrase_file]}" unless args[:passphrase_file].blank?

    `cd credentials && tar -czf credentials.tar.gz ./*`
    `gpg #{passphrase_options} -o credentials.tar.gz.gpg -c credentials/credentials.tar.gz`

  end

  desc "Encrypt for use as an environment variable"
  task :env_encrypt do |t, args|
    password = ENV['PASSWORD']
    raise "Please supply a password as an environment variable" unless password

    puts WithCred.encrypted
  end

  desc "Check that the environment variable credentials are correct"
  task :check => :environment do
    WithCred.check!
  end

  desc "Output a lockfile unique to the credentials set"
  task :lock => :environment do
    WithCred.lock
  end

end
