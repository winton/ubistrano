Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :ssh do
    desc 'Generate ssh keys and upload to server'
    task :default do
      ssh.keys.create
      ssh.keys.upload
    end
    
    namespace :keys do
      desc "Creates an rsa ssh key pair (local or remote)"
      task :create do
        if ask(msg(:ssh_keys_create))[0..0].downcase == 'l'
          system('ssh-keygen -t rsa') if yes(msg(:create_keys))
        else
          if yes(msg(:create_server_keys))
            pass = ask "Enter a password for this key:"
            sudo_each [
              "ssh-keygen -t rsa -N '#{pass}' -q -f /home/#{user}/.ssh/id_rsa",
              "chmod 0700 /home/#{user}/.ssh",
              "chown -R #{user} /home/#{user}/.ssh"
            ]
            sudo_puts "tail -1 /home/#{user}/.ssh/id_rsa.pub"
          end
        end unless yes(msg(:have_keys))
      end

      desc "Uploads local ssh public keys into remote authorized_keys"
      task :upload do
        if yes(msg(:upload_keys))
          keys = ask msg(:ssh_keys_upload), get_ssh_keys
          if keys.empty?
            ssh.setup if yes("No keys found. Generate ssh keys now?")
          else
            sudo_each [
              "mkdir -p /home/#{user}/.ssh",
              "touch /home/#{user}/.ssh/authorized_keys"
            ]
            add_line "/home/#{user}/.ssh/authorized_keys", keys.strip
            sudo_each [
              "chmod 0700 /home/#{user}/.ssh",
              "chmod 0600 /home/#{user}/.ssh/authorized_keys",
              "chown -R #{user} /home/#{user}/.ssh"
            ]
          end
        end
      end
    end
  end

end