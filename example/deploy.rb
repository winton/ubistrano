set :ubistrano, {
  :application => :my_app,
  :ec2_keys    => "#{File.dirname(__FILE__)}/ec2",
  :platform    => :rails,  # :php, :rails, :sinatra
  :repository  => 'git@github.com:user/my-app.git',
  
  :production => {
    :domains => [ 'myapp.com', 'www.myapp.com' ],
    :host    => '127.0.0.1'
  },
  
  :staging => {
    :domains => 'staging.myapp.com',
    :host    => '127.0.0.1'
  }
}

require 'ubistrano'