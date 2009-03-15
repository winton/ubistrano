Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :mysql do 
    namespace :create do
      desc "Create database and user"
      task :default, :roles => :db do
        mysql.create.user
        mysql.create.db
      end
      
      desc "Create database"
      task :db, :roles => :db do
        mysql_run "CREATE DATABASE #{db_table}"
      end
    
      desc "Create database user"
      task :user, :roles => :db do
        mysql_run [
          "CREATE USER '#{application}'@'localhost' IDENTIFIED BY '#{mysql_app_password}'",
          "GRANT ALL PRIVILEGES ON #{db_table}.* TO '#{application}'@'localhost'"
        ]
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
          "REVOKE ALL PRIVILEGES, GRANT OPTION FROM '#{application}'@'localhost'",
          "DROP USER '#{application}'@'localhost'"
        ]
      end
    end
    
    namespace :backup do
      desc "Upload local backup to remote"
      task :local_to_server, :roles => :db do
        from = File.expand_path("backups/#{backup_name}.bz2", FileUtils.pwd)
        if File.exists?(from)
          run_each "mkdir -p #{shared_path}/backups"
          upload from, "#{shared_path}/backups/#{backup_name}.bz2"
        else
          puts "Does not exist: #{from}"
        end
      end
      
      desc "Restore remote database from backup"
      task :restore, :roles => :db do
        run_each "bunzip2 < #{shared_path}/backups/#{backup_name}.bz2 | mysql -u #{application} --password=#{mysql_app_password} #{db_table}"
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
          "mysqldump --add-drop-table -u #{application} -p#{mysql_app_password} #{db_table} | bzip2 -c > #{shared_path}/db_backups/#{backup_name}.bz2"
        ]
      end
      
      def backup_name
        now = Time.now
        [ now.year, now.month, now.day ].join('-') + '.sql'
      end
    end
  end

end