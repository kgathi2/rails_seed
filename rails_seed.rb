# https://blog.codeship.com/building-a-json-api-with-rails-5/
def source_paths
  Array(super) +
    [File.expand_path(File.dirname(app_path)), File.expand_path(File.dirname(__FILE__))]
end

# To generate locally. Run outside the directory rails_seed
# rails new test2 -d postgresql -m ../GitHubPages/t/rails_seed.rb --api -B
@link = '.'

# rails new test2 -d postgresql -m https://raw.github.com/kgathi2/rails_seed/master/rails_seed.rb --api -B
# rails new test2 -d postgresql -m https://goo.gl/AMZ2J7 --api -B
#@link = 'https://raw.github.com/kgathi2/rails_seed/master'

def apply_file(folder,file)
  get "#{@link}/#{folder}/#{file}", "tmp/#{file}"
  apply "tmp/#{file}"
  remove_file "tmp/#{file}"
end

def copy_remote_file(local_folder,remote_folder,file,options={})
  get "#{@link}/#{local_folder}/#{file}", "tmp/#{file}"
  remote_folder = "#{remote_folder}/" if !remote_folder.empty?
  copy_file "tmp/#{file}", "#{remote_folder}#{file}", options
  remove_file "tmp/#{file}"
end

############# Run Setup scripts #############
scripts = %w(
  rack_attack.rb
  add_staging.rb
  setup_jsonb.rb
  figaro.rb
  sidekiq.rb
  hash_serializer.rb
  secrets_config.rb
  config_app.rb
  )

scripts.each do |file|
  apply_file('scripts',file)
end

############# Setup gems #############
gem 'rack-attack' # Rate limit api requests
gem 'figaro' # Environemental variables
gem 'sidekiq' # Background jobs
gem 'sidekiq-cron' # Cron Jobs
gem 'sidekiq-failures' # Sidekiq failure logging
gem 'sidekiq-unique-jobs'
gem 'sidekiq-throttler'
gem 'sinatra', require: false
# gem 'rack-protection', git: 'https://github.com/sinatra/sinatra.git'
gem 'pry-rails' # Awesome console
gem 'carrierwave' # File uploads and manipulation
gem 'mini_magick' # Image manipulation
gem 'ransack' # search
gem 'kaminari' # pagination
gem 'httparty'
gem 'dalli'
gem 'hashie'
# gem 'devise'
# gem 'omniauth'
# gem 'jwt'
# gem 'pundit'
# gem 'active_model_serializers'
# gem 'active_decorator'
# http://brewhouse.io/blog/2014/04/30/gourmet-service-objects.html
# gem 'services'

gem_group :development, :test do
  gem 'awesome_print'
  gem 'bullet'
  gem 'faker'
  gem 'brakeman', require: false
  gem 'rubocop', require: false
  gem 'letter_opener'
  gem 'guard-rails'
  gem 'guard-redis'
  gem 'guard-minitest', require: false
  gem 'guard-brakeman'
  gem 'guard-rubocop'
end

# Deployment
gem_group :development do
  # gem 'capistrano-harrow', git: 'https://github.com/harrowio/capistrano-harrow', tag: '0.3.1'
  gem 'capistrano', '~> 3.11'
  gem 'capistrano-rails'
  gem 'capistrano-bundler', require: false
  gem 'rvm1-capistrano3', require: false
  gem 'capistrano-postgresql', require: false
  gem 'capistrano3-puma', require: false#, github: 'seuros/capistrano-puma'
  gem 'capistrano-sidekiq', require: false
end

gem_group :test do
  gem 'guard-minitest', require: false
  gem 'minitest-reporters'
  gem 'factory_girl_rails'
  gem 'webmock'
  gem 'timecop'
  gem 'database_cleaner'
  gem 'simplecov', require: false
  gem 'shoulda'
  gem 'shoulda-matchers'
end

after_bundle do
  run "spring stop"
  run 'guard init'
  run 'cap install'

  cap_templates = %w(
    gemrc.erb
    localhost_crt.erb
    localhost_key.erb
    memcached.erb
    nginx.erb
    sidekiq_upstart.erb
    sidekiq_systemd.erb
    worker_upstart.erb
    )

  # nginx_unicorn.erb
  # unicorn.rb.erb
  # unicorn_init.erb
  # replace nginx_unicorn files with nginx_puma

  cap_templates.each do |file|
    copy_remote_file('capistrano/templates','lib/capistrano/templates',file)
  end

  cap_tasks = %w(
    memcached.rake
    nginx.rake
    postfix.rake
    postgresql.rake
    redis.rake
    puma.rake
    check.rake
    sidekiq.rake
    assets.rake
    figaro.rake
    )
  cap_tasks.each do |file|
    copy_remote_file('capistrano/tasks','lib/capistrano/tasks',file)
  end

  copy_remote_file('scripts','','Capfile',:force => true)

  @repo = ask("What git repo should I use. E.g 'git@example.com:me/my_repo.git ?")

  cap_scripts = %w(
    provision.rb
    setup.rb
    settings.rb
    deploy.rb
    hooks.rb
    finalize.rb
    )
  cap_scripts.each do |file|
    apply_file('capistrano',file)
  end

  # generate('devise:install')
  # generate('pundit:install')
  run 'rake db:create db:migrate'

  say <<-EOF
  #################################################
  ## Finally please edit the guardfile as suggested
  ## run with 'bundle exec guard'
  ##
  ## # Add this callback at the end of your test
  ## # suit watcher block to avoid test log bloat
  ## callback(:start_begin)  do
  ##   FileUtils.rm('log/test.log')
  ## end
  ##
  ## # group your tasks
  ## group :live, :test do
  ##  guard 'redis'
  ## end
  ##
  ## # Default group to run
  ## scope group: :test
  ##
  ## Set up the following common gems
  ##
  ## gem 'pg_search' # PG full text search
  ## gem 'devise' # Authentication
  ## gem 'pundit' # Authorization
  ## gem 'omniauth' # Authentication Oauth
  ## gem 'jwt' # JSON web token for api auth
  ## gem 'active_model_serializers' # Serializer for API
  ## gem 'active_decorator' # Decorator for model views
  ## gem 'services' # Authentication
  ## http://brewhouse.io/blog/2014/04/30/gourmet-service-objects.html
  ##
  ## Set up the server with a 'deploy' user ssh-key
  ## See readme for script or cloud-config
  ## Finish Server Setup. Add the server ip address
  ## in config/deploy/[staging.rb | production.rb]
  ## The run:
  ##
  ## cap [stage] provision
  ##
  ## Enjoy
  ##
  ## -Kariuki Gathitu
  #################################################

  EOF
end
