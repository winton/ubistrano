Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :mysql do 
    namespace :create do
      desc "Create database and user"
      task :default, :roles => :db do
        mysql.create.db
        mysql.create.user
      end
      
      desc "Create database"
      task :db, :roles => :db do
        mysql_run "CREATE DATABASE #{db_table}"
      end
    
      desc "Create database user"
      task :user, :roles => :db do
        mysql_run [
          "CREATE USER '#{db_user}'@'localhost' IDENTIFIED BY '#{db_pass}'",
          "GRANT ALL PRIVILEGES ON *.* TO '#{db_user}'@'localhost'"
        ]
      end
    end
    
    namespace :update do
      desc 'Update mysql root password'
      task :root_password, :roles => :db do
        old_pass = ask "Current root password? (default: none)"
        new_pass = ask "New root password? (default: none)"
        sudo "mysqladmin -u root #{old_pass.empty? ? '' : "--password=#{old_pass} "}password #{new_pass}"
      end
    end
  
    namespace :destroy do
      desc "Destroy database and user"
      task :default, :roles => :db do
        mysql.destroy.db
        mysql.destroy.user
      end
      
      desc "Destroy database"
      task :db, :roles => :db do
        mysql_run "DROP DATABASE #{db_table}"
      end
      
      desc "Destroy database user"
      task :user, :roles => :db do
        mysql_run [
          "REVOKE ALL PRIVILEGES, GRANT OPTION FROM '#{db_user}'@'localhost'",
          "DROP USER '#{db_user}'@'localhost'"
        ]
      end
    end
    
    namespace :backup do
      desc "Upload local backup to remote"
      task :local_to_server, :roles => :db do
        from = File.expand_path("~/db_backups/#{stage}/#{application}/#{backup_name}.bz2")
        if File.exists?(from)
          run_each "mkdir -p #{shared_path}/db_backups"
          upload from, "#{shared_path}/db_backups/#{backup_name}.bz2"
        else
          puts "Does not exist: #{from}"
        end
      end
      
      desc "Restore remote database from backup"
      task :restore, :roles => :db do
        run_each "bunzip2 < #{shared_path}/db_backups/#{backup_name}.bz2 | mysql -u #{db_user} --password=#{db_pass} #{db_table}"
      end
      
      desc "Backup database to local"
      task :to_local, :roles => :db do
        to_server
        system "mkdir -p ~/db_backups/#{stage}/#{application}"
        get "#{shared_path}/db_backups/#{backup_name}.bz2", File.expand_path("~/db_backups/#{stage}/#{application}/#{backup_name}.bz2")
      end
      
      desc "Backup database to remote"
      task :to_server, :roles => :db do
        run_each [
          "mkdir -p #{shared_path}/db_backups",
          "mysqldump --add-drop-table -u #{db_user} -p#{db_pass} #{db_table}_production | bzip2 -c > #{shared_path}/db_backups/#{backup_name}.bz2"
        ]
      end
      
      def backup_name
        now = Time.now
        [ now.year, now.month, now.day ].join('-') + '.sql'
      end
    end
  end

end