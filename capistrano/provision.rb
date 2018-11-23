create_file 'lib/capistrano/provision.rb' do <<-RUBY
def deploy_link
  repo = fetch(:repo_url)
  if repo['bitbucket']
    @git_service = 'Bitbucket'
    @link = repo.gsub(':','/').gsub('.git','/admin/deploy-keys/').gsub('git@','https://')
  elsif repo['github']
    @git_service = 'Github'
    @link = repo.gsub(':','/').gsub('.git','/settings/keys/').gsub('git@','https://')
  end
  {git_service: @git_service, link: @link}
end

namespace :provision do

  desc 'create swap'
  task :swap do
    on roles (:all) do
      system_details = capture(%(sudo lshw -class memory))
      puts "################# SYSTEM DETAILS #################"
      puts system_details
      if !test("[ -e /swapfile ]")
        set :swap_size, ask("size of swap space in GB(1,2,4)", 1)

        execute :sudo, "fallocate -l \#{fetch(:swap_size,1)}G /swapfile"
        execute :sudo, 'chmod 600 /swapfile'
        execute :sudo, 'mkswap /swapfile'
        execute :sudo, 'swapon /swapfile'
        execute :sudo, %{sh -c 'echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab'}
        execute :sudo, 'sysctl vm.swappiness=10'
        execute :sudo, %{sh -c 'echo "vm.swappiness=10" >> /etc/sysctl.conf'}
        execute :sudo, 'sysctl vm.vfs_cache_pressure=50'
        execute :sudo, %{sh -c 'echo "vm.vfs_cache_pressure = 50" >> /etc/sysctl.conf'}
        info "\#{fetch(:swap_size,1)}G Swap Installed"
      else
        info "Swapfile already created."
      end
    end
  end

  desc 'Install application environment'
  task :update_system do
    on roles(:all), in: :groups, limit: 3, wait: 10 do
      execute :sudo, 'apt-get -y update'
      execute :sudo, 'DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common build-essential zlib1g-dev libssl-dev libreadline-dev openssh-server libyaml-dev libcurl4-openssl-dev libxslt-dev libxml2-dev openssl curl autoconf ncurses-dev automake libtool bison'

      if test("[ -e ~/.ssh/id_rsa ]")
        info "SSH key exists. Skipping..."
      else
        execute %( echo "
  " | ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa) # for repo
      end
      info 'System updated'
    end
  end

  desc 'Install Essentials'
  task :essentials do
    on roles(:all), in: :groups, limit: 3, wait: 10 do
      execute :sudo, 'apt-get -y install curl wget vim less htop dialog'
      execute :sudo, 'apt-get -y install imagemagick libmagickwand-dev'
      execute :sudo, 'apt-get -y install systemd-sysv'
      execute :sudo, %(sed -i -e 's/^#PS1=/PS1=/' /root/.bashrc) # enable the colorful root bash prompt
      info 'Essentials installed'
    end
  end

  # https://www.digitalocean.com/community/tutorials/how-to-install-and-use-mosh-on-a-vps
  desc 'Install Mobile Shell for keeping ssh session alive'
  task :mosh do
    on roles(:all), in: :groups, limit: 3, wait: 10 do
      execute :sudo, ' apt-get install -y software-properties-common'
      execute :sudo, ' add-apt-repository -y ppa:keithw/mosh'
      execute :sudo, ' apt-get update'
      execute :sudo, ' apt-get -y install mosh'
      info 'Mobile Shell (mosh) installed'
    end
  end

  desc 'Install git'
  task :git do
    on roles(:all) do
      execute :sudo, 'apt-get -y install git-core'
      info 'Git Installed'
    end
  end

  desc 'Install the latest stable release of nginx'
  task :nginx do
  	on roles(:web) do
  		execute :sudo, 'apt-get -y install software-properties-common'
      execute :sudo, 'add-apt-repository -y ppa:nginx/stable' # get latest nginx
      execute :sudo, 'apt-get -y update' # update apt to nginx
      execute :sudo,  'apt-get -y install nginx nginx-extras'
      info 'Nginx Installed'
    end
  end

  desc 'Install Memcached'
  task :memcached do
    on roles (:app) do
      execute :sudo, 'apt-get -y update'
      execute :sudo, 'apt-get -y install memcached'
      info 'Memcached Installed'
    end
  end

  desc 'Install the latest relase of Node.js'
  task :nodejs do
    on roles (:app) do
      execute :sudo, 'add-apt-repository -y -r ppa:chris-lea/node.js'
      execute :sudo, 'apt-get -y update'
      execute :sudo, 'apt-get -y install nodejs'
      info 'Nodejs Installed'
    end
  end

  desc 'Install Postfix loopback only'
  task :postfix do
    on roles (:all) do
      execute :sudo, 'DEBIAN_FRONTEND=noninteractive apt-get -y install postfix'
      info 'Postfix Installed'
    end
  end

  desc 'Install the latest stable release of PostgreSQL.'
  task :postgresql do
    on roles (:db) do
      execute :sudo, %{sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'}
      execute :sudo, 'apt-get -y install wget ca-certificates'
      execute 'wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -'
      execute :sudo, 'apt-get -y update'
      execute :sudo, 'apt-get -y install postgresql postgresql-contrib pgadmin3 libpq-dev'
      info 'Postgresql Installed'
    end
  end

  desc 'Install the latest release of Redis on the server'
  task :redis do
    on roles (:app) do
      execute :sudo, 'apt-get install -y software-properties-common'
      execute :sudo, 'add-apt-repository -y ppa:chris-lea/redis-server'
      execute :sudo, 'apt-get -y update'
      execute :sudo, 'apt-get -y install redis-server'
      info 'Redis Installed'
    end
  end

  desc 'Install RVM and Ruby'
  task :rvm do
    on roles(:app) do
      execute %( gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3)
      execute :sudo, %(\\\\curl -sSL https://get.rvm.io | bash -s stable --ruby=\#{fetch(:rvm1_ruby_version)})
      # info "RVM and Ruby Installed"
      execute :sudo, %(echo "source /home/\#{fetch(:user)}/.rvm/scripts/rvm" > /tmp/rvm-source.sh)
      execute '. /tmp/rvm-source.sh'
      info "RVM and Ruby \#{fetch(:rvm1_ruby_version)} Installed"
    end
  end

  desc 'Install firewall and security on the server'
  task :security do
    on roles (:all) do
      # https://www.thefanclub.co.za/how-to/how-secure-ubuntu-1204-lts-server-part-1-basics
      # Install Firewall
      execute :sudo, 'apt-get install -y ufw fail2ban logcheck logcheck-database nmap logwatch libdate-manip-perl rkhunter psad'
      # execute :sudo, 'apt-get install -y tiger  chkrootkit' # IDS intrusion detection system
      info 'Firewall Installed'

      # Secure shared memory
      release = capture('lsb_release -r')[/\d+\.\d+/].to_f
      shm = (release > 12.04 ? '/dev/shm' : '/run/shm')
      execute :sudo, %{sh -c 'echo "tmpfs     \#{shm}     tmpfs     defaults,noexec,nosuid     0     0" >> /etc/fstab'}
      info 'Secured Shared Memory'

      # Network Hardening with sysctl
      execute :sudo, %{sh -c 'echo "
      # IP Spoofing protection
      net.ipv4.conf.all.rp_filter = 1
      net.ipv4.conf.default.rp_filter = 1

      # Ignore ICMP broadcast requests
      net.ipv4.icmp_echo_ignore_broadcasts = 1

      # Disable source packet routing
      net.ipv4.conf.all.accept_source_route = 0
      net.ipv6.conf.all.accept_source_route = 0 
      net.ipv4.conf.default.accept_source_route = 0
      net.ipv6.conf.default.accept_source_route = 0

      # Ignore send redirects
      net.ipv4.conf.all.send_redirects = 0
      net.ipv4.conf.default.send_redirects = 0

      # Block SYN attacks
      net.ipv4.tcp_syncookies = 1
      net.ipv4.tcp_max_syn_backlog = 2048
      net.ipv4.tcp_synack_retries = 2
      net.ipv4.tcp_syn_retries = 5

      # Log Martians
      net.ipv4.conf.all.log_martians = 1
      net.ipv4.icmp_ignore_bogus_error_responses = 1

      # Ignore ICMP redirects
      net.ipv4.conf.all.accept_redirects = 0
      net.ipv6.conf.all.accept_redirects = 0
      net.ipv4.conf.default.accept_redirects = 0 
      net.ipv6.conf.default.accept_redirects = 0

      # Ignore Directed pings
      net.ipv4.icmp_echo_ignore_all = 1
      " >> /etc/sysctl.conf'}
      execute :sudo, 'sysctl -p'
      info 'Hardened Network with sysctl'

      # Prevent IP Spoofing
      execute :sudo, %{sh -c 'echo "nospoof on" >> /etc/host.conf'}
    end
  end

  desc 'Set Permanent ENV variables'
  task :set_env do
    on roles (:app) do
      stage = fetch(:rails_env, fetch(:stage))
      env_file = "\#{fetch(:env_folder)}/#{app_name}_\#{stage}_env.sh"
      execute :sudo, %(bash -c 'echo "export RAILS_ENV="\#{stage}"" > \#{env_file}')
      execute :sudo, %(bash -c 'echo "export RACK_ENV="\#{stage}"" >> \#{env_file}')
    end
  end

  desc 'Finish Installation'
  task :finalize do
    on roles(:all), in: :sequence, wait: 5 do
      # TODO: Send sms after environment setup is complete. Bring me back from my coffee
      publickey = capture(%(cat ~/.ssh/id_rsa.pub))
      run_locally do
        execute "echo '\#{publickey}'"
      end
      repo = deploy_link
      info '#####################################################################'
      info '#####################################################################'
      info 'We have Copied the key to your clipboard.  '
      info "Just Paste the public key below to set up \#{repo[:git_service]} deploy-key. "
      info "\#{repo[:git_service]}: \#{repo[:link]}"
      info '#####################################################################'
      puts publickey
      info '#####################################################################'
      info 'Then run:'
      info 'cap [stage] setup'
      info '#####################################################################'
      info '#####################################################################'
    end
  end

  desc 'Provision the server'
  task :install do
    start = Time.now 
    invoke "provision:swap"
  	invoke "provision:update_system"
  	invoke "provision:essentials"
  	invoke "provision:mosh"
  	invoke "provision:git"
  	invoke "provision:nginx"
  	invoke "provision:memcached"
  	invoke "provision:nodejs"
  	invoke "provision:postgresql"
  	invoke "provision:redis"
  	invoke "provision:rvm"
  	invoke "provision:postfix"
  	invoke "provision:security"
    invoke "provision:set_env"
  	invoke "provision:finalize"
    install_time = (Time.now - start).divmod(60)
    puts "Provisioning took \#{install_time[0]} minutes, \#{install_time[1].round(1)} seconds"
  end

end
RUBY
end
