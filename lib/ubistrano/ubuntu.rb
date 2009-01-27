Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :ubuntu do
    desc "Set up a fresh Ubuntu server"
    task :default do
      puts space(msg(:about_templates))
      puts space(msg(:adduser)) unless yes("Have you already created the user defined in deploy.rb?")
      ssh.default
      ubuntu.config.default
      ubuntu.aptitude.default
      ubuntu.install.default
      ubuntu.restart
      puts space(msg(:ubuntu_finished))
    end
    
    desc "Restart Ubuntu server"
    task :restart do
      if yes(msg(:ubuntu_restart))
        sudo_each 'shutdown -r now'
      end
    end
    
    desc "Restart Ubuntu server and wait"
    task :restart_and_wait do
      if yes(msg(:ubuntu_restart))
        sudo_each 'shutdown -r now'
        exit unless yes('Please wait a little while for your server to restart. Continue?')
      end
    end
    
    namespace :aptitude do
      desc 'Run all aptitude tasks'
      task :default do
        if yes(msg(:aptitude_default))
          aptitude.update
          aptitude.upgrade
          aptitude.essential
        else
          exit unless yes(msg(:aptitude_instructions))
        end
        ubuntu.restart_and_wait
      end
      
      desc 'Aptitude update'
      task :update do
        sudo_puts 'aptitude update -q -y'
      end
      
      desc 'Aptitude upgrade'
      task :upgrade do
        sudo_puts 'aptitude upgrade -q -y'
      end
      
      desc 'Aptitude install build-essential'
      task :essential do
        sudo_puts 'aptitude install build-essential -q -y'
      end
    end
    
    namespace :config do
      desc 'Run all tasks'
      task :default do
        ubuntu.config.sudoers
        ubuntu.config.sshd_config
        ubuntu.config.iptables
      end

      desc "Updates server iptables"
      task :iptables do
        if yes(msg(:iptables))
          upload_from_erb '/etc/iptables.rules', binding, :folder => 'ubuntu'
          sudo_each [
            'iptables-restore < /etc/iptables.rules',
            'rm /etc/iptables.rules'
          ]
        end
      end
      
      desc "Updates sshd_config"
      task :sshd_config do
        if yes(msg(:sshd_config))
          set :ssh_port, port
          set :port, 22
          change_line '/etc/ssh/sshd_config', 'Port 22',              "Port #{port}"
          change_line '/etc/ssh/sshd_config', 'PermitRootLogin yes',  'PermitRootLogin no'
          change_line '/etc/ssh/sshd_config', 'X11Forwarding yes',    'X11Forwarding no'
          change_line '/etc/ssh/sshd_config', 'UsePAM yes',           'UsePAM no'
          remove_line '/etc/ssh/sshd_config', 'UseDNS .*'
          add_line    '/etc/ssh/sshd_config', 'UseDNS no'
          sudo_puts '/etc/init.d/ssh reload'
          set :port, ssh_port
        end
      end
      
      desc "Updates sudoers file"
      task :sudoers do
        if yes(msg(:sudoers))
          add_line '/etc/sudoers', "#{user} ALL=NOPASSWD: ALL"
        end
      end
    end
    
    namespace :install do
      desc 'Run all install tasks'
      task :default do
        ubuntu.install.apache
        ubuntu.install.git
        ubuntu.install.mysql
        ubuntu.install.mysqltuner
        ubuntu.install.perl
        ubuntu.install.php
        ubuntu.install.postfix
        ubuntu.install.ruby
        ubuntu.install.rubygems
        ubuntu.install.passenger
        ubuntu.install.god
        ubuntu.install.rails
        ubuntu.install.sinatra
        ubuntu.install.sphinx
      end
      
      desc 'Install Apache'
      task :apache, :roles => :web do
        if yes("May I install Apache?")
          sudo_puts [
            'aptitude install apache2 apache2-mpm-prefork apache2-utils apache2.2-common libapr1 libaprutil1 ssl-cert -q -y',
            'a2enmod rewrite',
            'a2enmod ssl',
            'a2dissite default'
          ]
        end
      end
      
      desc 'Install Git'
      task :git, :roles => :app do
        install_source(:git) do |path|
          sudo_puts [
            'apt-get build-dep git-core -q -y',
            make_install(path)
          ]
        end if yes("May I install Git?")
      end
      
      desc 'Install MySQL'
      task :mysql, :roles => :db do
        if yes("May I install MySQL?")
          sudo_puts 'aptitude install mysql-client-5.0 mysql-common mysql-server mysql-server-5.0 libmysqlclient15-dev libmysqlclient15off -q -y'
          ROOT.mysql.create.user
          exit unless yes(msg(:secure_mysql))
        end
      end
      
      desc "Install MySQLTuner"
      task :mysqltuner, :roles => :db do
        if yes(msg(:mysqltuner))
          bin = "/usr/local/bin"
          run_each [
            "cd #{bin} && sudo wget --quiet #{sources[:mysqltuner]}",
            "cd #{bin} && sudo chmod 0700 mysqltuner.pl",
            "cd #{bin} && sudo mv mysqltuner.pl mysqltuner"
          ]
          exit unless yes(msg(:mysqltuner_instructions))
        end
      end
      
      desc 'Install Perl'
      task :perl, :roles => :web do
        if yes("May I install Perl?")
          sudo_puts 'aptitude install libdbi-perl libnet-daemon-perl libplrpc-perl libdbd-mysql-perl -q -y'
        end
      end
      
      desc 'Install PHP'
      task :php, :roles => :web do
        if yes("May I install PHP?")
          sudo_puts 'aptitude install php5-common php5-mysql libapache2-mod-php5 php-pear php-mail php-net-smtp -q -y'
        end
      end
      
      desc 'Install Postfix'
      task :postfix, :roles => :web do
        if yes("May I install Postfix and set it up as a relay?")
          smtp  = ask 'What is your SMTP server address?'
          login = ask 'What is your SMTP server username?'
          pass  = ask 'What is your SMTP server password?'
          sudo_puts 'aptitude install postfix -q -y'
          add_line  '/etc/postfix/main.cf',
            'smtp_sasl_auth_enable = yes',
            'smtp_sasl_security_options = noanonymous',
            'smtp_sasl_password_maps = hash:/etc/postfix/saslpasswd',
            'smtp_always_send_ehlo = yes',
            "relayhost = #{smtp}"
          sudo_each 'touch /etc/postfix/saslpasswd'
          add_line  '/etc/postfix/saslpasswd', "#{smtp} #{login}:#{pass}"
          sudo_each [
            'postmap /etc/postfix/saslpasswd',
            '/etc/init.d/postfix restart'
          ]
        end
      end
      
      desc 'Install Ruby'
      task :ruby, :roles => :app do
        if yes("May I install Ruby?")
          sudo_puts "aptitude install libopenssl-ruby -q -y"
          install_source(:ruby) do |path|
            sudo_puts make_install(path)
            sudo_puts make_install(path) # install twice because openssl doesn't the first time
          end
        end
      end
      
      desc 'Install RubyGems'
      task :rubygems, :roles => :app do
        if yes("May I install RubyGems?")
          install_source(:rubygems) do |path|
            run_puts "cd #{path} && sudo ruby setup.rb"
          end
          gems.update
        end
      end
      
      desc 'Install Passenger'
      task :passenger, :roles => :app do
        if yes("May I install Passenger (mod_rails)?")
          sudo_puts 'aptitude install apache2-prefork-dev -q -y'
          gem_install :passenger
          ROOT.apache.reload if yes(msg(:passenger))
        end
      end
      
      desc 'Install God'
      task :god, :roles => :app do
        if yes(msg(:god))
          gem_install 'god'
          upload_from_erb '/etc/init.d/god', binding, :folder => 'ubuntu'
          sudo_each [
            ';cd /etc/init.d && sudo chmod +x god',
            'mkdir -p /usr/local/etc/god'
          ]
          upload_from_erb('/usr/local/etc/god.god',        binding, :folder => 'ubuntu')
          upload_from_erb('/usr/local/etc/god/apache.god', binding, :folder => 'ubuntu') if yes(msg(:god_apache))
          upload_from_erb('/usr/local/etc/god/mysql.god',  binding, :folder => 'ubuntu') if yes(msg(:god_mysql))
          upload_from_erb('/usr/local/etc/god/sshd.god',   binding, :folder => 'ubuntu') if yes(msg(:god_sshd))
          sudo_puts [
            'update-rc.d god defaults',
            '/etc/init.d/god start'
          ]
        end
      end
      
      desc 'Install Rails'
      task :rails, :roles => :app do
        if yes("May I install Rails?")
          gem_install :mysql
          gem_install :rails
        end
      end
      
      desc 'Install Sinatra'
      task :sinatra, :roles => :app do
        if yes("May I install Sinatra?")
          gem_install :do_mysql  # Datamapper
          gem_install 'dm-core'
          gem_install :sinatra   # Sinatra
        end
      end
      
      desc 'Install Sphinx'
      task :sphinx, :roles => :app do
        install_source(:sphinx) do |path|
          sudo_puts make_install(path)
        end if yes("May I install Sphinx?")
      end
    end
  end

end