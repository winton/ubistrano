Gem::Specification.new do |s|
  s.name    = 'ubistrano'
  s.version = '1.1.0'
  s.date    = '2008-12-14'
  
  s.summary     = "Provision and deploy to an Ubuntu/God/Apache/Passenger stack using Capistrano"
  s.description = "Provision and deploy to an Ubuntu/God/Apache/Passenger stack using Capistrano"
  
  s.author   = 'AppTower'
  s.email    = 'apptower@wintoni.us'
  s.homepage = 'http://github.com/AppTower/ubistrano'
  
  s.has_rdoc = false
  
  # = MANIFEST =
  s.files = %w[
    MIT-LICENSE
    README.markdown
    Rakefile
    changelog.markdown
    example/deploy.rb
    lib/ubistrano.rb
    lib/ubistrano/apache.rb
    lib/ubistrano/deploy.rb
    lib/ubistrano/gems.rb
    lib/ubistrano/helpers.rb
    lib/ubistrano/log.rb
    lib/ubistrano/mysql.rb
    lib/ubistrano/rails.rb
    lib/ubistrano/sinatra.rb
    lib/ubistrano/ssh.rb
    lib/ubistrano/stage.rb
    lib/ubistrano/ubuntu.rb
    templates/apache/virtual_host.erb
    templates/log/rotate.conf.erb
    templates/rails/database.yml.erb
    templates/sinatra/config.ru.erb
    templates/ubuntu/apache.god.erb
    templates/ubuntu/god.erb
    templates/ubuntu/god.god.erb
    templates/ubuntu/iptables.rules.erb
    templates/ubuntu/mysql.god.erb
    templates/ubuntu/sshd.god.erb
    ubistrano.gemspec
  ]
  # = MANIFEST =
end