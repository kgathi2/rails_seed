namespace :redis do
  %w(start stop restart status).each do |command|
    desc "#{command} redis"
    task "#{command}" do
      on roles (:app) do
        execute :sudo, "service redis-server #{command}"
      end
    end
  end
end
