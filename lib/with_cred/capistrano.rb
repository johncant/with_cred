module Capistrano::Configuration::Namespace::Namespace
def with_credentials_run(*args)
  pwd = WithCred::Deployment.password
  cred = WithCred::Deployment.encrypted_credentials

  if pwd
    args[0] = "ENCRYPTED_CREDENTIALS='#{cred}' #{args[0]}"
  end

  if cred
    args[0] = "PASSWORD='#{pwd}' #{args[0]}"
  end

  args[0] = "export #{args[0]}"

  run(*args)
end
end

Capistrano::Configuration.instance.load do

  namespace :credentials do
    desc "ask for credentials password"
    task :password_prompt do
      ENV['PASSWORD'] = Capistrano::CLI.password_prompt("Please enter password to decrypt credentials.")
    end

    desc "check"
    task :check do
      credentials.password_prompt
      WithCred.check!
    end

    desc "lock"
    task :lock do
      credentials.password_prompt
      WithCred.lock
    end

  end

end

