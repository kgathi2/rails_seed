# set :puma_user, fetch(:user)
# set :puma_rackup, -> { File.join(current_path, 'config.ru') }
# set :puma_state, "#{fetch(:shared_path)}/tmp/pids/puma.state"
# set :puma_pid, "#{fetch(:shared_path)}/tmp/pids/puma.pid"
# set :puma_bind, "unix://#{fetch(:shared_path)}/tmp/sockets/puma.sock"    #accept array for multi-bind
# set :puma_default_control_app, "unix://#{fetch(:shared_path)}/tmp/sockets/pumactl.sock"
# set :puma_conf, "#{fetch(:shared_path)}/puma.rb"
# set :puma_access_log, "#{fetch(:shared_path)}/log/puma_access.log"
# set :puma_error_log, "#{fetch(:shared_path)}/log/puma_error.log"
# set :puma_role, :app
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
# set :puma_threads, [0, 16] #Min and Max threads per worker
# set :puma_workers, 2 #Change to match your CPU core count
# set :puma_worker_timeout, nil
set :puma_init_active_record, true
# set :puma_preload_app, false
# set :puma_plugins, []  #accept array of plugins

namespace :puma do
  desc 'Provide link to app'
  task :check_cpu_cores do
    on roles :app do
      cores = capture 'nproc'
      set :puma_workers, cores.to_i #Change to match your CPU core count
    end
  end

  desc 'Provide link to app'
  task :showapplink do
    on roles :app do
      ipaddress = capture (%{ifconfig | awk '/inet addr/{print substr($2,6)}' | awk 'NR==1'})
      info '#####################################################################'
      info '#####################################################################'
      info 'You site is up on the links below'
      info ' '
      info "http://#{ipaddress}"
      info "https://#{ipaddress}"
      info ' '
      info '#####################################################################'
      info '#####################################################################'
    end
  end
  
end
