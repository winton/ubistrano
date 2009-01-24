Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :deploy do
    desc "Restart application"
    task :restart, :roles => :app, :except => { :no_release => true } do
      run_each "touch #{current_path}/tmp/restart.txt"
    end

    desc "Start application"
    task :start, :roles => :app do
      apache.virtual_host.enable
    end

    desc "Stop application"
    task :stop, :roles => :app do
      apache.virtual_host.disable
    end
    
    desc "Deploy for the first time"
    task :first, :roles => :app do
      sudo_each [
        "mkdir -p #{base_dir}",
        "chown -R #{user}:#{user} #{base_dir}"
      ]
      mysql.create.db
      deploy.setup
      case platform
      when :php
        deploy.update
      when :rails
        rails.config.default
        deploy.update
        deploy.migrate
      when :sinatra
        sinatra.config.default
        deploy.update
        sinatra.install
      end
      apache.virtual_host.create
      deploy.start
      apache.reload
    end
  
    desc "Stop servers and destroy all files"
    task :destroy, :roles => :app do
      sudo_each "rm -Rf #{deploy_to}"
      mysql.destroy.db
      apache.virtual_host.destroy
    end
    
    namespace :web do
      task :disable do
        pub = "#{deploy_to}/current/public"
        sudo_each "mv #{pub}/maintenance.html #{pub}/index.html"
      end
      
      task :enable do
        pub = "#{deploy_to}/current/public"
        sudo_each "mv #{pub}/index.html #{pub}/maintenance.html"
      end
    end
  end
  
end