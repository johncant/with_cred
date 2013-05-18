require 'rails'

module WithCred
  module Rails
    class Railtie < ::Rails::Railtie
      rake_tasks do
        Dir[File.expand_path('../tasks/*.rake', __FILE__)].each { |f| load f }
      end

      config.before_configuration do
        WithCred.add_from_environment_vars
        WithCred.add_from_files
      end
    end
  end
end
