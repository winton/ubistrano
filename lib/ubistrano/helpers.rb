require 'erb'

Capistrano::Configuration.instance(:must_exist).load do

  # Install

  def gem_install(name, options='')
    sudo_puts "gem install #{name} #{options} --no-rdoc --no-ri -q"
  end
  
  def install_source(source)
    path, source = unpack_source source
    yield path
    sudo "rm -Rf #{source}"
  end
  
  def make_install(path)
    ";cd #{path} && ./configure && make && sudo make install"
  end

  def unpack_source(source)
    url  = sources[source]
    name = File.basename url
    src  = "/home/#{user}/sources"
    base = nil
    [ 'tar.gz', 'tgz' ].each do |ext|
      base = name[0..((ext.length + 2) * -1)] if name.include?(ext)
    end
    run_each [
      "mkdir -p #{src}",
      "cd #{src} && wget --quiet #{url}",
      "tar -xzvf #{src}/#{name} -C #{src}"
    ]
    [ "#{src}/#{base}", src ]
  end


  # Files
  
  def add_line(file, *lines)
    lines.each do |line|
      sudo_each "echo \"#{line}\" | sudo tee -a #{file}"
    end
  end
  
  def change_line(file, from, to)
    sudo_each "sed -i 's/#{from}/#{to}/' #{file}"
  end
  
  def remove_line(file, *lines)
    lines.each do |line|
      change_line file, line, ''
    end
  end

  def get_ssh_key(key)
    key.gsub!('.pub', '')
    key = File.expand_path("~/.ssh/#{key}")
    key = Dir[key + '.pub', key].first
    if key
      keys = File.open(key).collect { |line| line.strip.empty? ? nil : line.strip }.compact
      keys.join("\n")
    else
      nil
    end
  end

  def upload_from_erb(destination, bind=nil, options={})
    # options[ :chown  => owner of file (default: deploy user),
    #          :chmod  => 0644 etc
    #          :folder => 'postfix' etc,
    #          :name   => name of template if differs from destination ]
    if destination.respond_to?(:uniq)
      destination.each { |d| upload_from_erb d, bind, options }
    else
      template = File.basename destination
      template = template[1..-1] if template[0..0] == '.'
      folder   = options[:folder] ? options[:folder] + '/' : ''
      template = File.expand_path("../../templates/#{folder}#{options[:name]||template}.erb", File.dirname(__FILE__))
      template = File.read template
      sudo "touch #{destination}"
      sudo "chown #{user} #{destination}"
      put ERB.new(template).result(bind || binding), destination
      sudo("chown #{options[:chown]} #{destination}") if options[:chown]
      sudo("chmod #{options[:chmod]} #{destination}") if options[:chmod]
    end
  end


  # MySQL

  def mysql_run(sql)
    if sql.respond_to?(:uniq)
      sql.each { |s| mysql_run s }
    else
      run "echo \"#{sql}\" | #{mysql_call}"
    end
  end

  def mysql_call
    "mysql -f -u root --password=#{mysql_root_password || ''}"
  end


  # Questions

  def ask(question, default='')
    question = "\n" + question.join("\n") if question.respond_to?(:uniq)
    answer = Capistrano::CLI.ui.ask(space(question)).strip
    answer.empty? ? default : answer
  end

  def yes(question)
    question = "\n" + question.join("\n") if question.respond_to?(:uniq)
    question += ' (y/n)'
    ask(question).downcase.include? 'y'
  end
  
  def space(str)
    "\n#{'=' * 80}\n#{str}"
  end


  # Runners

  def run_each(*args, &block)
    cmd  = args[0]
    sudo = args[1]
    if cmd.respond_to?(:uniq)
      cmd.each  { |c| run_each c, sudo, &block }
    elsif sudo
      puts space("sudo #{cmd}")
      sudo(cmd) { |ch, st, data| block.call(data) if block }
    else
      puts space(cmd)
      run(cmd)  { |ch, st, data| block.call(data) if block }
    end
  end

  def sudo_each(cmds, &block)
    run_each cmds, true, &block
  end

  def run_puts(cmds, &block)
    run_each(cmds) { |data| puts data }
  end

  def sudo_puts(cmds, &block)
    sudo_each(cmds) { |data| puts data }
  end


  # Messages

  def msg(type)
    case type
    when :about_templates
"Let's set up an Ubuntu server! (Tested with 8.04 LTS Hardy)

With each task, Ubistrano will describe what it is doing, and wait for a yes/no."
    when :add_user
"Please ssh into your server (use -i only for EC2):
  ssh root@#{host} -i ~/.ssh/id_rsa-#{application}

Add your deploy user:
  adduser #{user}

Continue?"
    when :aptitude_default
"Do you want me to run aptitude update, upgrade, and install build-essential?
If not, instructions for doing it manually will be displayed."
    when :aptitude_instructions
"Please run these manually:
  sudo aptitude update
  sudo aptitude upgrade
  sudo aptitude build-essential

Continue?"
    when :create_keys
"May I generate an rsa ssh key pair in your ~/.ssh folder?"
    when :create_server_keys
"May I generate an rsa ssh key pair on the server?
The public key will be displayed for adding to your GitHub account."
    when :ec2_finished
"All finished! Run the following commands:
  sudo chmod 600 ~/.ssh/id_rsa-#{application}
  cap ubuntu"
    when :god
"May I install God?" 
    when :god_apache
"Would you like God to monitor apache?
See #{File.expand_path '../../', File.dirname(__FILE__)}/templates/ubuntu/apache.god.erb"
    when :god_mysql
"Would you like God to monitor mysql?
See #{File.expand_path '../../', File.dirname(__FILE__)}/templates/ubuntu/mysql.god.erb"
    when :god_sshd
"Would you like God to monitor sshd?
See #{File.expand_path '../../', File.dirname(__FILE__)}/templates/ubuntu/sshd.god.erb"
    when :god_finished
"Please run the following commands:
  ssh #{user}@#{host}
  sudo /etc/init.d/god start
  sudo /etc/init.d/god start

Continue?"
    when :iptables
"May I update your server's iptables, limiting access to SSH, HTTP, HTTPS, and ping only?
See #{File.expand_path '../../', File.dirname(__FILE__)}/templates/ubuntu/iptables.rules.erb"
    when :logrotate
"May I add a logrotate entry for this application?
See #{File.expand_path '../../', File.dirname(__FILE__)}/templates/log/rotate.conf.erb"
    when :logrotate_suggest
"All finished! Run `cap log:rotate` to add log rotating.
"
    when :mysqltuner
"Would you like to install MySQLTuner and receive instructions for running it?"
    when :mysqltuner_instructions
"Please ssh to your server and run `sudo mysqltuner`.
Continue?"
    when :passenger
"Please run the following commands:
  ssh #{user}@#{host}
  sudo passenger-install-apache2-module

The apache config file is found at /etc/apache2/apache2.conf.
Reload apache?"
    when :run_ubuntu_install
"Client and server configuration complete.

Please run the second half of the install:
  cap ubuntu:install

"
    when :secure_mysql
"It is highly recommended you run mysql_secure_installation manually:
  ssh #{user}@#{host}
  mysql_secure_installation
  
See http://dev.mysql.com/doc/refman/5.1/en/mysql-secure-installation.html
Continue?"
    when :sinatra_install
"Would you like to run install.rb (from your app) if it exists?"
    when :sshd_config
"May I update your server's sshd_config with the following settings?
  Port #{port}
  PermitRootLogin no
  X11Forwarding no
  UsePAM no
  UseDNS no
"
when :ssh_config
"May I update your server's ssh_config with the following settings?
  StrictHostKeyChecking no
"
    when :ubuntu_restart
"Its probably a good idea to restart the server now.
OK?"
    when :ubuntu_restart_2
"Please wait a little while for your server to restart.

Continue?"
    when :ubuntu_finished
"That's it! Glad you made it.

Use `cap deploy:first` to set up your PHP, Rails, or Sinatra app.
Use `cap deploy` for all subsequent deploys.

"
    when :upload_keys
"Would you like to upload a ssh key to the deploy user's authorized_keys?"
    when :upload_keys_2
"Please enter a key in ~/.ssh to copy to the the deploy user's authorized_keys."
    when :visudo
"Please ssh into your server (use -i only for EC2):
  ssh root@#{host} -i ~/.ssh/id_rsa-#{application}

Edit your sudoers file:
  visudo

Add the following line:
  deploy ALL=NOPASSWD: ALL

Continue?"
    end
  end
  
end