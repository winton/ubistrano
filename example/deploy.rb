set :ubistrano, {
  :application  => :my_app,
  :platform     => :rails,  # :php, :rails, :sinatra
  :repository   => 'git@github.com:user/my-app.git',
  
  :production => {
    :domain => [ 'myapp.com', 'www.myapp.com' ],
    :host   => '127.0.0.1'
  },
  
  :staging => {
    :domain => 'staging.myapp.com',
    :host   => '127.0.0.1'
  }
}

require 'ubistrano'