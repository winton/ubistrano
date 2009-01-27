Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :ec2 do
    desc "Set up a new EC2 instance and provision"
    task :default, :roles => :web do
      ec2.key_pair.install
      ec2.instance.create
      ec2.security.group.setup unless yes("Have you set up the default security group?")
      exit unless yes("Add the instance's IP address to config/deploy.rb. Continue?")
      puts msg(:visudo)
      ubuntu
    end
    
    namespace :instance do      
      desc "Create a fresh Hardy instance"
      task :create do
        options = {
          :image_id => ask('Press enter for Ubuntu Hardy or enter an AMI image id: ', 'ami-1c5db975'),
          :key_name => "#{application}"
        }
        instance = ec2_api.run_instances(options).instancesSet.item[0]
        instance_id = instance.instanceId
        pp instance
        ip = ec2_api.allocate_address.publicIp
        ec2_api.associate_address(:instance_id => instance_id, :public_ip => ip)
        puts "Your instance id is: #{instance_id}"
        puts "Your IP address  is: #{ip}"
      end
      
      desc "Restart an instance"
      task :restart do
        ec2.instances
        pp ec2_api.reboot_instances(:instance_id => ask("Restart which instance ids?"))
      end
      
      desc "Destroy an instance"
      task :destroy do
        ec2.instances
        instance_id = ask("Terminate which instance ids?")
        ec2_api.terminate_instances(:instance_id => instance_id)
        ip = ec2_api.describe_addresses.addressesSet.item.select { |x| x.instanceId == instance_id }.first
        ec2_api.release_address(:public_ip => ip.publicIp) if ip
      end
    end
    
    desc "List your EC2 instances"
    task :instances do
      pp ec2_api.describe_instances
    end
    
    desc "List IPs for this EC2 account"
    task :ips do
      pp ec2_api.describe_addresses
    end
    
    namespace :key_pair do
      desc "Install key pair for SSH"
      task :install do
        begin
          out = ec2_api.create_keypair(:key_name => application.to_s)
          key = out.keyMaterial
        rescue EC2::InvalidKeyPairDuplicate
          ec2.key_pair.remove
          ec2.key_pair.install
        end
        File.open(File.expand_path("~/.ssh/id_rsa-#{application}"), 'w') { |f| f.write key }
        `chmod 600 ~/.ssh/id_rsa-#{application}`
      end

      desc "Install key pair for SSH"
      task :remove do
        ec2_api.delete_keypair(:key_name => application.to_s)
        `rm ~/.ssh/id_rsa-#{application}`
      end
    end
    
    namespace :security do
      namespace :group do
        desc "Open standard ports for default security group"
        task :setup do
          [ 22, 80, 443 ].each do |port|
            ec2_api.authorize_security_group_ingress(
              :group_name => 'default', :cidr_ip => '0.0.0.0/0', :from_port => port, :to_port => port, :ip_protocol => 'tcp'
            )
          end
        end
        
        desc "Describe default security group"
        task :describe do
          pp ec2_api.describe_security_groups(:group_name => 'default')
        end
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
      @ec2_api ||= EC2::Base.new(:access_key_id => ec2_access_key, :secret_access_key => ec2_secret_key)
    end
  end
  
end