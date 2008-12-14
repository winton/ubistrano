Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :apache do
    desc "Reload apache settings"
    task :reload, :roles => :web do
      sudo_puts "/etc/init.d/apache2 reload"
    end
    
    desc "Restart apache"
    task :restart, :roles => :web do
      sudo_puts "/etc/init.d/apache2 restart"
    end
    
    namespace :virtual_host do
      desc "Create a new virtual host"
      task :create, :roles => :web do
        upload_from_erb "/etc/apache2/sites-available/#{application}_#{stage}", binding, :name => 'virtual_host', :folder => 'apache'
      end
      
      desc "Enable a virtual host"
      task :enable, :roles => :web do
        sudo_puts "a2ensite #{application}_#{stage}"
      end
      
      desc "Destroy a virtual host"
      task :destroy, :roles => :web do
        apache.virtual_host.disable
        sudo_each "rm /etc/apache2/sites-available/#{application}_#{stage}"
      end
      
      desc "Disable a virtual host"
      task :disable, :roles => :web do
        sudo_puts "a2dissite #{application}_#{stage}"
      end
    end
  end

end