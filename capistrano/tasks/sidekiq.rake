# https://github.com/seuros/capistrano-sidekiq/wiki
# set :sidekiq_config, -> { File.join(shared_path, 'config', 'sidekiq.yml') }
# set	:sidekiq_default_hooks, true
# set :sidekiq_pid, File.join(shared_path, 'tmp', 'pids', 'sidekiq.pid')
# set :sidekiq_env, fetch(:rack_env, fetch(:rails_env, fetch(:stage)))
# set :sidekiq_log, File.join(shared_path, 'log', 'sidekiq.log')
# set :sidekiq_options, nil
# set :sidekiq_require, nil
# set :sidekiq_tag, nil
# set :sidekiq_config, nil
# set :sidekiq_queue, nil
# set :sidekiq_timeout, 10
# set :sidekiq_role, :app
# set :sidekiq_processes, 1
# set :sidekiq_options_per_process, nil
# set :sidekiq_concurrency, nil
# set :sidekiq_monit_templates_path, 'config/deploy/templates'
# set :sidekiq_monit_use_sudo, true
# set :sidekiq_cmd, "#{fetch(:bundle_cmd, "bundle")} exec sidekiq" # Only for capistrano2.5
# set :sidekiqctl_cmd, "#{fetch(:bundle_cmd, "bundle")} exec sidekiqctl" # Only for capistrano2.5

# Sidekiq::Stats.new.reset
# Sidekiq.redis { |r| puts r.flushall }


# cap sidekiq:quiet                  # Quiet sidekiq (stop processing new tasks)
# cap sidekiq:respawn                # Respawn missing sidekiq proccesses
# cap sidekiq:restart                # Restart sidekiq
# cap sidekiq:rolling_restart        # Rolling-restart sidekiq
# cap sidekiq:start                  # Start sidekiq
# cap sidekiq:stop                   # Stop sidekiq