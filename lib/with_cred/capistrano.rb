# Can't figure out how to require this file only for capistrano tasks.
# It's not required by default, so feel free to copypasta

Capistrano::Configuration.instance(:must_exist).load do

  def with_credentials_run(*args)
    pwd = ENV['PASSWORD']
    cred = WithCred.encrypted

    if pwd
      args[0] = "ENCRYPTED_CREDENTIALS='#{cred}' ; #{args[0]}"
    end

    if cred
      args[0] = "PASSWORD='#{pwd}' ; #{args[0]}"
    end

    run(*args)
  end


  namespace :credentials do
    desc "ask for credentials password"
    task :password_prompt do
      ENV['PASSWORD'] = Capistrano::CLI.password_prompt("Please enter password to decrypt credentials.")
    end

    desc "check"
    task :check do
      credentials.password_prompt
      with_credentials_run "bundle exec rake credentials:check"
    end

    desc "lock"
    task :lock do
      credentials.password_prompt
      WithCred.lock
    end

  end

end

