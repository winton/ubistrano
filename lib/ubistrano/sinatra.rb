Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :sinatra do    
    namespace :config do
      desc "Creates config.ru in shared config"
      task :default do
        run "mkdir -p #{shared_path}/config"
        Dir[File.expand_path('../../templates/rails/*', File.dirname(__FILE__))].each do |f|
          upload_from_erb "#{shared_path}/config/#{File.basename(f, '.erb')}", binding, :folder => 'rails'
        end
      end
      
      desc "Copies files in the shared config folder into our app"
      task :to_app, :roles => :app do
        run "cp -Rf #{shared_path}/config/* #{release_path}"
      end
    end
  end
  
end