Ubistrano
=========

Provision and deploy to an Ubuntu/God/Apache/Passenger stack using Capistrano.

Goals
-----

* Provision a solid Ubuntu Hardy application server in one command (<code>cap ubuntu</code>)
* Deploy PHP, Rails, and Sinatra apps
* Be descriptive about what is going on and allow the user to opt out
* Simplify the deploy.rb file

The stack
---------

* Apache
* Git
* MySQL
* MySQLTuner
* Perl
* PHP
* Postfix (relay)
* Ruby
* RubyGems
* Passenger (mod\_rails)
* God
* Rails
* Sinatra
* Sphinx


Getting started
---------------

### Install gem

	gem install AppTower-ubistrano

### Capify your project

	capify .

### Edit config/deploy.rb

<pre>
set :ubistrano, {
  :application => :my_app,
  :platform    => :rails,  # :php, :rails, :sinatra
  :repository  => 'git@github.com:user/my-app.git',

  :ec2 => {
    :access_key => '',
    :secret_key => ''
  },

  :production => {
    :domains => [ 'myapp.com', 'www.myapp.com' ],
    :ssl     => [ 'myapp.com' ],
    :host    => '127.0.0.1'
  },

  :staging => {
    :domains => [ 'staging.myapp.com' ],
    :host    => '127.0.0.1'
  }
}

require 'ubistrano'
</pre>

Ubistrano uses the same Capistrano options you've come to love, but provides defaults and a few extra options as well.

Feel free to add standard options like :user to the stage groups.

Set up your Ubuntu Hardy server
-------------------------------

### From your app directory

<pre>cap ubuntu</pre>

### Example output

<pre>
=================================================================================
Let's set up an Ubuntu server! (Tested with 8.04 LTS Hardy)

With each task, Ubistrano will describe what it is doing, and wait for a yes/no.

=================================================================================
Have you already created the user defined in deploy.rb? (y/n)
</pre>

Deploy your app
---------------

All apps should have a <code>public</code> directory.

### First deploy

	cap deploy:first
	
### Subsequent deploys

	cap deploy


Deploy to staging
-----------------

Use any capistrano task, but replace `cap` with `cap staging`.

### Example

	cap staging deploy:first