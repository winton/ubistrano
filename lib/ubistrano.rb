
# Require helpers and recipes
Dir["#{File.dirname(__FILE__)}/ubistrano/*.rb"].each { |f| require f }


Capistrano::Configuration.instance(:must_exist).load do
  
  # Reference ROOT when namespaces clash
  ROOT = self
  
  # Default package versions
  ubistrano[:versions] ||= {}
  ubistrano[:versions].merge!(
    :git            => '1.6.0.4',
    :mysecureshell  => '1.1',
    :rails          => '2.2.2',
    :ruby           => '1.8.7-p72',
    :rubygems       => '1.3.1',
    :sphinx         => '0.9.8.1'
  )
  
  # Merge ubistrano hash with capistrano
  ubistrano.each do |key, value|
    value.respond_to?(:keys) ?
      value.each { |k, v| set "#{key}_#{k}".intern, v } :
      set(key, value)
  end
  
  # Set default capistrano values
  set :db_user,   fetch(:db_user,   'app')
  set :db_pass,   fetch(:db_pass,   '')
  set :platform,  fetch(:platform,  :rails)
  set :port,      fetch(:port,      22)
  set :stage,     fetch(:stage,     :production)
  set :use_sudo,  fetch(:use_sudo,  false)
  set :user,      fetch(:user,      'deploy')
  set :sources,   fetch(:sources,   {
    :git           => "http://kernel.org/pub/software/scm/git/git-#{versions_git}.tar.gz",
    :mysecureshell => "http://internap.dl.sourceforge.net/sourceforge/mysecureshell/MySecureShell-#{versions_mysecureshell}_source.tgz",
    :mysqltuner    => "http://mysqltuner.com/mysqltuner.pl",
    :ruby          => "ftp://ftp.ruby-lang.org/pub/ruby/#{versions_ruby.split('.')[0..1].join('.')}/ruby-#{versions_ruby}.tar.gz",
    :rubygems      => "http://rubyforge.org/frs/download.php/45905/rubygems-#{versions_rubygems}.tgz",
    :sphinx        => "http://www.sphinxsearch.com/downloads/sphinx-#{versions_sphinx}.tar.gz"
  })
  
  # Rails plugins
  set :app_helpers,     fetch(:app_helpers,     false)
  set :rails_widget,    fetch(:rails_widget,    false)
  set :ultrasphinx,     fetch(:ultrasphinx,     false)
  set :thinking_sphinx, fetch(:thinking_sphinx, false)
  set :attachment_fu,   fetch(:attachment_fu,   false)
  set :asset_packager,  fetch(:asset_packager,  false)
  after('deploy:update_code', 'rails:config:app_helpers')     if app_helpers
  after('deploy:update_code', 'rails:config:asset_packager')  if asset_packager
  after('deploy:update_code', 'rails:config:attachment_fu')   if attachment_fu
  after('deploy:update_code', 'rails:config:rails_widget')    if rails_widget
  after('deploy:update_code', 'rails:config:ultrasphinx')     if ultrasphinx
  after('deploy:update_code', 'rails:config:thinking_sphinx') if thinking_sphinx
    
  # Git by default
  set :scm,              :git
  set :deploy_via,       :remote_cache
  set :repository_cache, 'git_cache'
  ssh_options[:paranoid] = false

  # Events
  on :before, 'setup_stage', :except => [ :staging, :testing ]  # Executed before every task
  after('deploy:update_code', 'rails:config:to_app'  ) if platform == :rails
  after('deploy:update_code', 'sinatra:config:to_app') if platform == :sinatra
  
end
