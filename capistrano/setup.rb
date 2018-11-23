create_file 'lib/capistrano/setup.rb' do <<-RUBY
namespace :setup do

	desc 'Setup Memcached'
  task :memcached do
    on roles (:app) do
      template 'memcached.erb', '/tmp/memcached.conf'
      execute :sudo, 'mv /tmp/memcached.conf /etc/memcached.conf'
    end
    invoke 'memcached:restart'
  end

  desc 'Setup self ssl cert and key'
  task :ssl_cert do
    on roles (:web) do
      template 'localhost_crt.erb', '/tmp/localhost.crt'
      execute :sudo, "mv /tmp/localhost.crt /etc/ssl/certs/\#{fetch(:application)}_\#{fetch(:stage)}.crt"
      template 'localhost_key.erb', '/tmp/localhost.key'
      execute :sudo, "mv /tmp/localhost.key /etc/ssl/private/\#{fetch(:application)}_\#{fetch(:stage)}.key"
      invoke 'nginx:restart'
    end
  end

  desc 'Setup nginx and its configurations for the application'
  task :nginx_puma do
    on roles (:web) do
      execute :sudo, 'mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.default' # backup config file
      template 'nginx.erb', '/tmp/nginx_confd'
      execute :sudo, 'mv /tmp/nginx_confd /etc/nginx/nginx.conf'
      execute :sudo, 'rm -f /etc/nginx/sites-enabled/default'
      invoke 'puma:nginx_config' #Add site to sites-enabled
      invoke 'puma:config' 
      invoke 'nginx:restart'
    end
  end

  desc 'Setup Postgresql'
  task :postgresql do
  	on roles(:db) do
      as 'postgres' do
        if !test 'psql -d postgres -c "\\du" | grep deploy'
          invoke 'postgresql:create_database'
        else
          info "Databases already created."
        end
      end
    end
  end

  desc 'Set up Ruby'
  task :gemrc do
    on roles(:app) do
      template 'gemrc.erb', '/tmp/gemrc'
      execute :sudo, 'bash -c "cat /tmp/gemrc >> ~/.gemrc"'
      execute :sudo, 'bash -c "cat /tmp/gemrc >> /home/deploy/.gemrc"'
      info 'Gem Default for production server'
      execute :sudo, %(bash -c "echo "rvm_trust_rvmrcs_flag=1" >> /home/\#{fetch(:user)}/.rvmrc")
    end
  end

  desc 'update gems and install bundler'
  task :gems do
    on roles(:app) do
      execute :rvm, fetch(:rvm1_ruby_version), :do, 'ruby -v'
      execute :rvm, fetch(:rvm1_ruby_version), :do, 'gem update --system'
      execute :rvm, fetch(:rvm1_ruby_version), :do, 'gem install bundler --no-ri --no-rdoc'
      info 'Ruby Gems updated'
    end
  end

  desc 'Install Postfix loopback only'
  task :postfix do
    on roles (:all) do
      execute :sudo, 'bash -c  "echo "postfix postfix/main_mailer_type select Internet Site" | debconf-set-selections"'
      execute :sudo, 'bash -c  "echo "postfix postfix/mailname string localhost" | debconf-set-selections"'
      execute :sudo, 'bash -c  "echo "postfix postfix/destinations string localhost.localdomain, localhost" | debconf-set-selections"'
      execute :sudo, '/usr/sbin/postconf -e "inet_interfaces = loopback-only";'
      execute :sudo, '/usr/sbin/postconf -e "local_transport = error:local delivery is disabled"'
      invoke 'postfix:restart'
    end
  end

  desc 'Setup security'
  task :firewall do
    on roles (:all) do
      execute :sudo, 'ufw logging on'
      execute :sudo, 'ufw default deny'
      execute :sudo, 'ufw allow ssh'
      execute :sudo, 'ufw allow http'
      execute :sudo, 'ufw allow https'
      execute :sudo, ' ufw allow 60000:60020/udp' # Mosh
      execute :sudo, "echo 'y' |sudo ufw enable"
    end
  end

  desc 'Setup Sidekiq'
  task :sidekiq do
    on roles :app do
      execute "mkdir -p \#{shared_path}/config"
      
      version = capture("lsb_release -r | awk '{print $2}'").to_f
      if version >= 15.04
        info("Setting up sidekiq with systemd")
        template 'sidekiq_systemd.erb', '/tmp/sidekiq.service'
        execute :sudo, "mv /tmp/sidekiq.service \#{fetch(:systemd_sidekiq_config)}"
        execute :sudo, "systemctl enable sidekiq"
      else
        info("Setting up sidekiq with upstart")
        template 'sidekiq_upstart.erb', '/tmp/sidekiq_conf'
        execute :sudo, "mv /tmp/sidekiq_conf \#{fetch(:upstart_sidekiq_config)}"

        template 'worker_upstart.erb', '/tmp/worker_conf'
        execute :sudo, "mv /tmp/worker_conf \#{fetch(:upstart_worker_config)}"
      end
    end
  end

  desc 'Setup environment'
  task :finalize do
    on roles(:all), in: :sequence, wait: 5 do
      # Setup Bitbucket deployment keys
      execute 'ssh-keyscan  bitbucket.org  >> ~/.ssh/known_hosts' # add bitbucket key to server for passwordless deployment
      execute 'ssh -T git@bitbucket.org ' # add bitbucket key to server for passwordless deployment
      # Setup postgresql and ruby
      ipaddress = capture (%{ifconfig | awk '/inet addr/{print substr($2,6)}' | awk 'NR==1'})
      info '#####################################################################'
      info '#####################################################################'
      info 'We are now ready to Deploy'
      info 'Setup your Environmental Variables at config/application.yml'
      info 'then run the command below'
      info ' '
      info 'cap [ENV] deploy '
      info ' '
      info "After that you can find your app at http://\#{ipaddress} or https://\#{ipaddress}"
      info '#####################################################################'
      info '#####################################################################'
    end
  end

  desc 'Setup the server'
  task :install do
    start = Time.now 
    invoke "setup:memcached"
    invoke "setup:postgresql"
    invoke "setup:gemrc"
    invoke "setup:gems"
    invoke "setup:postfix"
    invoke "setup:firewall"
    invoke "setup:sidekiq"
    invoke "setup:ssl_cert"
    invoke "setup:nginx_puma"
    invoke "setup:finalize"
    install_time = (Time.now - start).divmod(60)
    puts "Setup took \#{install_time[0]} minutes, \#{install_time[1].round(1)} seconds"
  end

end

RUBY
end
