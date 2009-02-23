Ubistrano
=========

Provision and deploy to an Ubuntu/God/Apache/Passenger stack using Capistrano and EC2.

Goals
-----

* Create an Ubuntu Hardy EC2 instance in one command (<code>cap ec2</code>)
* Provision a solid Ubuntu Hardy application server in one command (<code>cap ubuntu</code>)
* Deploy PHP, Rails, and Sinatra apps
* Be descriptive about what is going on and allow the user to opt out
* Simplify the <code>deploy.rb</code> file

The stack
---------

* Apache
* EC2 (optional)
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

	gem install winton-ubistrano

### Ubify your project

<pre>
cd your_project
ubify .
</pre>

* Runs <code>capify</code>
* Creates <code>config/deploy.example.rb</code>
* Adds <code>config/deploy.rb</code> to your project's <code>.gitignore</code>

### Copy config/deploy.example.rb to config/deploy.rb

It should look like this:

<pre>
set :ubistrano, {
  :application => :my_app,
  :platform    => :rails,  # :php, :rails, :sinatra
  :repository  => 'git@github.com:user/my-app.git',

  :ec2 => {
    :access_key => '',
    :secret_key => ''
  },

  :mysql => {
    :password => ''
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

Edit deploy.rb to the best of your ability. If setting up an EC2 instance, be sure to provide your AWS keys. Your IP address will be provided later.

Feel free to move any options into or out of the stage groups.

Create your EC2 instance
------------------------

### From your app directory

<pre>
cap ec2
</pre>

### Example output

<pre>
================================================================================
Press enter for Ubuntu Hardy or enter an AMI image id:
</pre>

Set up your Ubuntu Hardy server
-------------------------------

### From your app directory

<pre>
cap ubuntu
</pre>

### Example output

<pre>
================================================================================
Let's set up an Ubuntu server! (Tested with 8.04 LTS Hardy)

With each task, Ubistrano will describe what it is doing, and wait for a yes/no.

================================================================================
Please ssh into your server (use -i only for EC2):
  ssh root@174.129.232.34 -i ~/.ssh/id_rsa-studicious

Edit your sudoers file:
  visudo

Add the following line:
  deploy ALL=NOPASSWD: ALL

Continue? (y/n)
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

Use any capistrano task, but replace <code>cap</code> with <code>cap staging</code>.

### Example

	cap staging deploy:first