############ Run Setup Git Repo and Deploy Scripts #############
create_file 'lib/capistrano/deploy.rb' do <<-RUBY
def template(from, to, as_root = false)
  template_path = File.expand_path("../templates/\#{from}", __FILE__)
  template = ERB.new(File.new(template_path).read).result(binding)
  upload! StringIO.new(template), to

  sudo "chmod 644 \#{to}" # ensure default file chmod
  sudo "chown root:root \#{to}" if as_root == true
end

namespace :deploy do
	desc 'Start application'
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
      invoke 'puma:start'
    end
  end

  desc 'Stop application'
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
      invoke 'puma:stop'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
      # invoke 'puma:phased-restart'
      invoke 'puma:restart'
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

	RUBY
end