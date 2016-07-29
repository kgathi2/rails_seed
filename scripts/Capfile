# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# Include tasks from other gems included in your Gemfile
require 'rvm1/capistrano3'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'capistrano/sidekiq'

require 'capistrano/puma'
require 'capistrano/puma/nginx'   # if you want to upload a nginx site template
# require 'capistrano/puma/workers' # if you want to control the workers (in cluster mode)
# require 'capistrano/puma/jungle'  # if you need the jungle tasks
# require 'capistrano/puma/monit'   # if you need the monit tasks

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
