Version 1.2.4
-------------

* Complete EC2/Ubuntu Hardy provision and deploy tested with Rails and Sinatra

Version 1.2.3
-------------

* Added bin/ubify which executes capify in addition to copying config/deploy.example.rb and adding config/deploy.rb to the project's .gitignore
* Added mysql option in deploy.rb
* Minor ubuntu:install fixes

Version 1.2.2
-------------

* Hardened cap ec2 -> cap ubuntu -> cap ubuntu:install
* There should be nothing to cause the user to stop and restart the tasks

Version 1.2.0
-------------

* New EC2 tasks
* EC2 setup and `cap ubuntu` provision tested

Version 1.1.0
-------------

* Sinatra apps deploying properly
* PHP and Rails apps should be deploying properly
* `cap ubuntu` flow hardened

Version 1.0.3
-------------

* `cap ubuntu` tested on Ubuntu 8.04 LTS Hardy
* App deploying not at all tested