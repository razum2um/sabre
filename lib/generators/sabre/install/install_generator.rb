module Sabre
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../templates",__FILE__)

      desc "Creates a sabre initializer file to your application."
			
      def copy_initializer
        template "sabre.rb", "config/initializers/sabre.rb"
      end
    end
  end
end
