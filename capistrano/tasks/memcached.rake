namespace :memcached do
  # How to clear memcached cache
  # http://www.cyberciti.biz/faq/linux-unix-flush-contents-of-memcached-instance/
  # or run Rails.cache.clear in rake task in app
  %w(start stop restart status).each do |command|
    desc "#{command} Memcached"
    task command do
      on roles (:app) do
        execute :sudo, "service memcached #{command}"
      end
    end
  end
end
