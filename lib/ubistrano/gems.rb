Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :gems do  
    desc "List gems on remote server"
    task :list, :roles => :app do
      run_puts "gem list"
    end
    
    desc "Update gems on remote server"
    task :update, :roles => :app do
      sudo_each [
        "gem update --system",
        "gem update"
      ]
    end
    
    desc "Install a remote gem"
    task :install, :roles => :app do
      gem_install ask('Enter the name of the gem to install:')
    end
    
    desc "Uninstall a remote gem"
    task :uninstall, :roles => :app do
      gem_name = ask 'Enter the name of the gem to remove:'
      sudo "gem uninstall #{gem_name}"
    end
  end

end