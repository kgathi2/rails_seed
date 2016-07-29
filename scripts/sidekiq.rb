application do <<-RUBY
  config.active_job.queue_adapter = :sidekiq
  # config.active_job.queue_name_prefix = Rails.env
  # config.active_job.queue_name_delimiter = '.'
  RUBY
end

############# Sidekiq Route #############
route <<-RUBY
  require "sidekiq/web"
  require 'sidekiq/cron/web'
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end if ['production','staging'].include?(Rails.env)
  mount Sidekiq::Web, at: :queue, as: :queue
RUBY

############# Sidekiq Initializer #############
initializer 'sidekiq.rb', <<-RUBY
Sidekiq.configure_server do |config|
  config.redis = { namespace: "#{app_name}_\#{Rails.env}" }

  # sidekiq-failures
  config.failures_max_count = 5000 # false # to disable limit
  # config.failures_default_mode = :all # :exhausted :off 
  # config.server_middleware do |chain|
  #   chain.add Sidekiq::Middleware::Server::RetryJobs, :max_retries => 5
  # end
  # config.client_middleware do |chain|
  #   chain.add Sidekiq::Middleware::Server::RetryJobs, :max_retries => 5
  # end
  
  # https://github.com/gevans/sidekiq-throttler
  # config.server_middleware do |chain|
  #   chain.add Sidekiq::Throttler, storage: :redis, threshold: 50, period: 1.hour
  # end

  # schedule_file = "config/schedule.yml"
  # if File.exists?(schedule_file)
  #   Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
  # end
end

Sidekiq.configure_client do |config|
  config.redis = { namespace: "#{app_name}_\#{Rails.env}" }
  # config.client_middleware do |chain|
  #   chain.add Sidekiq::Middleware::Client::RetryJobs, :max_retries => 5
  # end
end

# Sidekiq::Cron::Job.destroy_all!
schedule_file = "config/schedule.yml"
if File.exists?(schedule_file)
  Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file) rescue puts 'Redis is not on. No Cron jobs started'
end

Sidekiq.default_worker_options = {
  unique: :until_executing,
  unique_args: ->(args) { args.first.except('job_id') }
}
RUBY

############# Sidekiq Config #############
create_file 'config/sidekiq.yml' do <<-EOF
# Sample configuration file for Sidekiq.
# Options here can still be overridden by cmd line args.
#   sidekiq -C config.yml
---
:verbose: false
:pidfile: ./tmp/pids/sidekiq.pid
:concurrency: 5
staging:
  :concurrency: 2
  :pidfile: /home/deploy/#{app_name}/shared/tmp/pids/sidekiq.pid
  :logfile: /home/deploy/#{app_name}/shared/log/sidekiq.log
production:
  :concurrency: 10
  :pidfile: /home/deploy/#{app_name}/shared/tmp/pids/sidekiq.pid
  :logfile: /home/deploy/#{app_name}/shared/log/sidekiq.log
# Set timeout to 8 on Heroku, longer if you manage your own systems.
:timeout: 30
:queues:
  - default
  - [myqueue, 2]
EOF
end

############# Sidekiq Cron Config #############
create_file 'config/schedule.yml' do <<-EOF
# # http://crontab.guru/
# first_job:
#   cron: "00 00 * * * Africa/Nairobi" # 12am
#   class: "HardWorker"
#   queue: default
#   args:
#     action: first_action
#     _aj_symbol_keys: ["action"]

# second_job:
#   cron: "00 8-21/4 * * * Africa/Nairobi" # 8-21/4
#   class: "HardWorker"
#   queue: default
#   args:
#     action: second_action
#     _aj_symbol_keys: ["action"]
EOF
end
