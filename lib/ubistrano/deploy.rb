Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :deploy do
    desc "Restart application"
    task :restart, :roles => :app, :except => { :no_release => true } do
      run_each [
        "mkdir #{current_path}/tmp",
        "touch #{current_path}/tmp/restart.txt"
      ]
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
      deploy.update
      apache.virtual_host.create
      case platform
      when :rails
        rails.config.default
        deploy.migrate
      when :sinatra
        sinatra.config.default
        sinatra.install
      end
      deploy.start
      apache.reload
    end
  
    desc "Stop servers and destroy all files"
    task :destroy, :roles => :app do
      deploy.stop
      sudo "rm -Rf #{deploy_to}"
      mysql.destroy.db
    end
  end
  
end