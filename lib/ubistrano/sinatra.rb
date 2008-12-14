Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :sinatra do
    desc "Runs install.rb if exists"
    task :install do
      if yes(msg(:sinatra_install))
        run_puts "if [ -e #{current_path}/install.rb ]; then sudo ruby #{current_path}/install.rb; fi"
      end
    end
    
    namespace :config do
      desc "Creates config.ru in shared config"
      task :default do
        run "mkdir -p #{shared_path}/config"
        upload_from_erb "#{shared_path}/config/config.ru", binding, :folder => 'sinatra'
      end
      
      desc "Copies files in the shared config folder into our app"
      task :to_app, :roles => :app do
        run "cp -Rf #{shared_path}/config/* #{release_path}"
      end
    end
  end
  
end