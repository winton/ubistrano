Gem::Specification.new do |s|
  s.name    = 'ubistrano'
  s.version = '1.2.4'
  s.date    = '2008-03-15'
  
  s.summary     = "Provision and deploy to an Ubuntu/God/Apache/Passenger stack using Capistrano"
  s.description = "Provision and deploy to an Ubuntu/God/Apache/Passenger stack using Capistrano"
  
  s.author   = 'Winton Welsh'
  s.email    = 'mail@wintoni.us'
  s.homepage = 'http://github.com/winton/ubistrano'
  
  s.add_dependency 'amazon-ec2', '>= 0.3.2'
  s.executables = ["ubify"]
  s.has_rdoc = false
  
  # = MANIFEST =
  s.files = %w[
    MIT-LICENSE
    README.markdown
    Rakefile
    bin/ubify
    changelog.markdown
    example/deploy.rb
    lib/ubistrano.rb
    lib/ubistrano/apache.rb
    lib/ubistrano/deploy.rb
    lib/ubistrano/ec2.rb
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