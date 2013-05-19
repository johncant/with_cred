Capistrano::Configuration.instance.load do

  namespace :password do
    desc "ask for credentials password"
    task :prompt do
      WithCred::Deployment.password = Capistrano::CLI.password_prompt("Please enter password to decrypt credentials.")
    end
  end

end
