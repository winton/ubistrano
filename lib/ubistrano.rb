
require 'EC2'
require 'pp'

# Require helpers and recipes
Dir["#{File.dirname(__FILE__)}/ubistrano/*.rb"].each { |f| require f }


Capistrano::Configuration.instance(:must_exist).load do
  
  # Default capistrano/ubistrano values
  set :ubistrano, {
    :base_dir         => '/var/www',
    :db_user          => 'app',
    :db_pass          => '',
    :deploy_via       => :remote_cache,
    :domains          => [],
    :platform         => :rails,
    :plugins          => {},
    :port             => 22,
    :repository_cache => 'git_cache',
    :scm              => :git,
    :ssl              => [],
    :stage            => :production,
    :use_sudo         => false,
    :user             => 'deploy',
    :versions         => {}
  }.merge(ubistrano)
  
  # Default plugins
  ubistrano[:plugins] = {
    :app_helpers     => false,
    :asset_packager  => false,
    :attachment_fu   => false,
    :rails_widget    => false,
    :thinking_sphinx => false
  }.merge(ubistrano[:plugins])
  
  # Default versions
  ubistrano[:versions] = {
    :git            => '1.6.0.4',
    :mysecureshell  => '1.1',
    :rails          => '2.2.2',
    :ruby           => '1.8.7-p72',
    :rubygems       => '1.3.1',
    :sphinx         => '0.9.8.1'
  }.merge(ubistrano[:versions])
  
  # Merge ubistrano hash with capistrano
  ubistrano.each do |key, value|
    value.respond_to?(:keys) ?
      value.each { |k, v| set "#{key}_#{k}".intern, v } :
      set(key, value)
  end
  
  # Default sources
  set :sources, {
    :git           => "http://kernel.org/pub/software/scm/git/git-#{versions_git}.tar.gz",
    :mysecureshell => "http://internap.dl.sourceforge.net/sourceforge/mysecureshell/MySecureShell-#{versions_mysecureshell}_source.tgz",
    :mysqltuner    => "http://mysqltuner.com/mysqltuner.pl",
    :ruby          => "ftp://ftp.ruby-lang.org/pub/ruby/#{versions_ruby.split('.')[0..1].join('.')}/ruby-#{versions_ruby}.tar.gz",
    :rubygems      => "http://rubyforge.org/frs/download.php/45905/rubygems-#{versions_rubygems}.tgz",
    :sphinx        => "http://www.sphinxsearch.com/downloads/sphinx-#{versions_sphinx}.tar.gz"
  }.merge(fetch(:sources, {}))
  
  # Events
  on :before, 'setup_stage', :except => [ :staging, :testing ] # Executed before every task
  after('deploy:update_code', 'rails:config:to_app'  )        if platform == :rails
  after('deploy:update_code', 'sinatra:config:to_app')        if platform == :sinatra
  after('deploy:update_code', 'rails:config:app_helpers')     if plugins_app_helpers
  after('deploy:update_code', 'rails:config:asset_packager')  if plugins_asset_packager
  after('deploy:update_code', 'rails:config:attachment_fu')   if plugins_attachment_fu
  after('deploy:update_code', 'rails:config:rails_widget')    if plugins_rails_widget
  after('deploy:update_code', 'rails:config:thinking_sphinx') if plugins_thinking_sphinx
  
  # Other options
  ssh_options[:paranoid] = false
  
  # Reference ROOT when namespaces clash
  ROOT = self
  
end
