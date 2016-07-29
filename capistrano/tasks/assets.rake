# hhttps://gist.github.com/basti/9232976
# https://gist.github.com/Jesus/80ef0c8db24c6d3a2745
# Clear existing task so we can replace it rather than "add" to it.
Rake::Task["deploy:compile_assets"].clear 

namespace :deploy do
  
  desc 'Compile assets'
  task :assets_compile => [:set_rails_env] do
    # invoke 'deploy:assets:precompile'
    invoke 'deploy:assets:precompile_local'
    invoke 'deploy:assets:backup_manifest'
  end

  namespace :assets do
    desc "Precompile assets locally and then rsync to web servers" 
    task :precompile_local do 
      # compile assets locally
      run_locally do
        execute "RAILS_ENV=#{fetch(:stage)} rake db:create"
        execute "RAILS_ENV=#{fetch(:stage)} bundle exec rake assets:precompile"
      end
     
      # rsync to each server
      local_dir = "./public/assets/"
      on roles(:web) do
        # this needs to be done outside run_locally in order for host to exist
        remote_dir = "#{host.user}@#{host.hostname}:#{shared_path}/public/assets/"
        run_locally { execute "rsync -av --delete #{local_dir} #{remote_dir}" }
      end
      # clean up
      run_locally { execute "rm -rf #{local_dir}" }
    end
  end

end