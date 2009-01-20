Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :ec2 do
    desc "Set up an ec2 instance"
    task :default, :roles => :web do
      ec2.install.api_tools
    end
    
    namespace :instance do
      desc "Set up an Ubuntu Hardy instance"
      task :setup do
        options = {
          :image_id => ask('Press enter for Ubuntu Hardy or enter an AMI image id: ', 'ami-1c5db975'),
          :key_name => '#{ec2_key_pair}'
        }
        # Create security group
        begin
          ec2_api.describe_security_groups(:group_name => 'ubistrano')
        rescue EC2::InvalidGroupNotFound
          pp ec2_api.create_security_group(:group_name => 'ubistrano')
          [ 22, 80 ].each do |port|
            pp ec2_api.authorize_security_group_ingress(
              :group_name => 'ubistrano', :cidr_ip => '0.0.0.0/0', :from_port => port, :to_port => port, :ip_protocol => 'tcp'
            )
          end
        end
        instance = ec2_api.run_instances(options).instancesSet.item[0]
        puts "Your instance id is: #{instance.instanceId}"
      end
      
      desc "Restart an instance"
      task :restart do
        ec2.instances
        pp ec2_api.reboot_instances(:instance_id => ask("Restart which instance ids?"))
      end
      
      desc "Destroy an instance"
      task :destroy do
        ec2.instances
        pp ec2_api.terminate_instances(:instance_id => ask("Terminate which instance ids?"))
      end
    end
    
    desc "List your EC2 instances"
    task :instances do
      pp ec2_api.describe_instances
    end
    
    namespace :key_pair do
      desc "Install key pair for SSH"
      task :install do
        begin
          key = ec2_api.create_keypair(:key_name => ec2_key_pair).keyMaterial
        rescue EC2::InvalidKeyPairDuplicate
          ec2.key_pair.remove
          ec2.key_pair.install
        end
        File.open(File.expand_path("~/.ssh/id_rsa-#{ec2_key_pair}"), 'w') { |f| f.write key }
        "chmod 600 ~/.ssh/id_rsa-#{ec2_key_pair}"
      end

      desc "Install key pair for SSH"
      task :remove do
        ec2_api.delete_keypair(:key_name => ec2_key_pair)
        `rm ~/.ssh/id_rsa-#{ec2_key_pair}`
      end
    end
    
    namespace :api_tools do
      desc "Install ec2 api tools locally"
      task :install, :roles => :web do
        `cd ~ && curl http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip -O`
        `cd ~ && unzip ec2-api-tools.zip`
        `cd ~ && rm ec2-api-tools.zip`
        `mv ~/ec2-api-tools-* ~/.ec2`
      end
      
      desc "Install ec2 api tools locally"
      task :remove, :roles => :web do
        `rm -Rf ~/.ec2`
      end
    end
    
    def ec2_api
      EC2::Base.new(:access_key_id => ec2_access_key, :secret_access_key => ec2_secret_key)
    end
  end
  
end