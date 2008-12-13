Capistrano::Configuration.instance(:must_exist).load do
 
  namespace :log do
    desc "Add logrotate entry for this application"
    task :rotate, :roles => :app do
      if yes(msg(:iptables))
        upload_from_erb '/etc/rotate.conf', binding, :folder => 'log'
        sudo_each [
          'cp -f /etc/logrotate.conf /etc/logrotate2.conf',
          'chmod 777 /etc/logrotate2.conf',
          'cat /etc/rotate.conf >> /etc/logrotate2.conf',
          'cp -f /etc/logrotate2.conf /etc/logrotate.conf',
          'rm -f /etc/logrotate2.conf',
          'rm -f /etc/rotate.conf'
        ]
      end
    end
  end
  
end