# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ubistrano}
  s.version = "1.2.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Winton Welsh"]
  s.date = %q{2009-06-28}
  s.default_executable = %q{ubify}
  s.email = %q{mail@wintoni.us}
  s.executables = ["ubify"]
  s.extra_rdoc_files = ["README.markdown"]
  s.files = ["bin", "bin/ubify", "changelog.markdown", "example", "example/deploy.rb", "gemspec.rb", "lib", "lib/ubistrano", "lib/ubistrano/apache.rb", "lib/ubistrano/deploy.rb", "lib/ubistrano/ec2.rb", "lib/ubistrano/gems.rb", "lib/ubistrano/helpers.rb", "lib/ubistrano/log.rb", "lib/ubistrano/mysql.rb", "lib/ubistrano/rails.rb", "lib/ubistrano/sinatra.rb", "lib/ubistrano/ssh.rb", "lib/ubistrano/stage.rb", "lib/ubistrano/ubuntu.rb", "lib/ubistrano.rb", "MIT-LICENSE", "Rakefile", "README.markdown", "templates", "templates/apache", "templates/apache/virtual_host.erb", "templates/log", "templates/log/rotate.conf.erb", "templates/rails", "templates/rails/database.yml.erb", "templates/ubuntu", "templates/ubuntu/apache.god.erb", "templates/ubuntu/god.erb", "templates/ubuntu/god.god.erb", "templates/ubuntu/iptables.rules.erb", "templates/ubuntu/mysql.god.erb", "templates/ubuntu/sshd.god.erb", "ubistrano.gemspec"]
  s.homepage = %q{http://github.com/winton/ubistrano}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Provision and deploy to an Ubuntu/God/Apache/Passenger stack using Capistrano}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<amazon-ec2>, ["= 0.4.5"])
    else
      s.add_dependency(%q<amazon-ec2>, ["= 0.4.5"])
    end
  else
    s.add_dependency(%q<amazon-ec2>, ["= 0.4.5"])
  end
end
