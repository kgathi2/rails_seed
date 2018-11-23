############ Run Setup Git Repo and Deploy Scripts #############
remove_file 'config/deploy.rb'
create_file 'config/deploy.rb' do <<-RUBY
# config valid only for current version of Capistrano
lock '~> 3.11'

set :application, "#{app_name}"
set :user, 'deploy'
set :repo_url, "#{@repo}" 

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/\#{fetch(:user)}/\#{fetch(:application)}"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system', 'public/assets') # , 'vendor/bundle', 'public/uploads'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :env_folder, '/etc/profile.d'
set :rvm1_ruby_version, '2.3.1'
set :rvm1_map_bins, -> { fetch(:rvm_map_bins).to_a.concat( %w{rake gem bundle ruby sidekiq sidekiqctl}) }

set :memcached_memory_limit, 128
set :pg_user, -> { fetch(:user) }
set :pg_database, -> { "\#{fetch(:application)}_\#{fetch(:rails_env) || fetch(:stage) }" }
set :confirm_drop, ask(", are you sure do you want to drop \#{fetch(:stage)} database (YES/NO): ", 'NO')

set :systemd_sidekiq_config, -> { "/etc/systemd/system/sidekiq.service" }
set :upstart_sidekiq_config, -> { "/etc/init/sidekiq.conf" }
set :upstart_worker_config, -> { "/etc/init/worker.conf" }

load 'lib/capistrano/provision.rb'
load 'lib/capistrano/setup.rb'
load 'lib/capistrano/deploy.rb'
load 'lib/capistrano/hooks.rb'

	RUBY
end
