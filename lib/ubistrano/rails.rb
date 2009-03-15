Capistrano::Configuration.instance(:must_exist).load do

  namespace :rails do
    namespace :config do
      desc "Creates database.yml in the shared config"
      task :default, :roles => :app do
        run "mkdir -p #{shared_path}/config"
        Dir[File.expand_path('../../templates/rails/*', File.dirname(__FILE__))].each do |f|
          upload_from_erb "#{shared_path}/config/#{File.basename(f, '.erb')}", binding, :folder => 'rails'
        end
      end
      
      desc "Set up app with app_helpers" 
      task :app_helpers do
        run "cd #{release_path} && script/plugin install git://github.com/winton/app_helpers.git"
        run "cd #{release_path} && rake RAILS_ENV=production quiet=true app_helpers"
      end
      
      desc "Configure attachment_fu"
      task :attachment_fu, :roles => :app do
        run_each [
          "mkdir -p #{shared_path}/media",
          "ln -sf #{shared_path}/media #{release_path}/public/media"
        ]
        sudo_each [
          "mkdir -p #{release_path}/tmp/attachment_fu",
          "chown -R #{user} #{release_path}/tmp/attachment_fu"
        ]
      end
      
      desc "Configure asset_packager" 
      task :asset_packager do
        run "cd #{release_path} && rake RAILS_ENV=production asset:packager:build_all"
      end
      
      desc "Configure rails_widget"
      task :rails_widget, :roles => :app do
        run "cd #{release_path} && rake RAILS_ENV=production widget:production"
      end
      
      desc "Copies yml files in the shared config folder into our app config"
      task :to_app, :roles => :app do
        run "cp -Rf #{shared_path}/config/* #{release_path}/config"
      end
      
      namespace :thinking_sphinx do
        desc "Configures thinking_sphinx"
        task :default, :roles => :app do
          sudo ";cd #{release_path} && rake RAILS_ENV=production ts:config"
        end
        
        desc "Stop thinking_sphinx"
        task :stop, :roles => :app do
          sudo ";cd #{release_path} && rake RAILS_ENV=production ts:stop"
        end
        
        desc "Start thinking_sphinx"
        task :start, :roles => :app do
          sudo ";cd #{release_path} && rake RAILS_ENV=production ts:start"
        end
        
        desc "Restart thinking_sphinx"
        task :restart, :roles => :app do
          rails.config.thinking_sphinx.stop
          rails.config.thinking_sphinx.start
        end
      end
    end
    
    desc "Intialize Git submodules"
    task :setup_git, :roles => :app do
      run "cd #{release_path}; git submodule init; git submodule update"
    end
  end

end