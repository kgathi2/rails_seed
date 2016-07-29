namespace :postgresql do
# set_default(:pg_dump_path) { "#{current_path}/tmp" }
# set_default(:pg_dump_file) { "#{application}_dump.sql" }
# set_default(:pg_local_dump_path) { File.expand_path("../../../tmp", __FILE__) }
# set_default(:pg_pid) { "/var/run/postgresql/9.1-main.pid" }

  desc 'Create a database for this application.'
  task :create_database do
    on roles :db do
      db_password = SecureRandom.hex
      execute :sudo, %( -u postgres psql -c "create user #{fetch(:pg_user)} with password '#{db_password}';")
      execute :sudo, %( -u postgres psql -c "create database #{fetch(:pg_database)} owner #{fetch(:pg_user)};")
      execute :sudo, %(bash -c 'echo "export DB_PASSWORD="#{db_password}"" > #{fetch(:env_folder)}/peza_zetu_database.sh')
    end
  end

  desc 'Drop the database for this application.'
  task :drop_database do
    on roles :db do
      if fetch(:confirm_drop) == 'YES'
        invoke "deploy:stop"
        invoke "sidekiq:stop"
        db_password = SecureRandom.hex
        execute :sudo, %( -u postgres psql -c "drop database #{fetch(:pg_database)};")
        execute :sudo, %( -u postgres psql -c "drop user #{fetch(:pg_user)};")
        # TODO Reset sidekiq for this app
      else
        info "Database drop aborted"
      end
    end
  end

  desc "Reset Database"
  task :reset do
    invoke 'postgresql:drop_database'
    invoke 'postgresql:create_database'
  end

  desc "Stop Postgresql running."
  task :stop do
    on roles :db do
      execute :sudo, 'service postgresql stop'
    end
  end

  desc "Start Postgresql running."
  task :start do
    on roles :db do
      execute :sudo, 'service postgresql start'
    end
  end

  desc "remove Postgresql running."
  task :purge do
    on roles :db do
      invoke 'postgresql:stop'
      execute :sudo, 'apt-get -y --purge remove postgresql\*'
    end
  end


  # # # backup ad restore
  # pg_dump -U deploy yourapp_staging -f yourapp_staging.sql
  # scp deploy@stagingserver.com:~/yourapp_staging.sql log/yourapp_staging.sql 

  # pg_dump -U deploy yourapp_production -f yourapp_production.sql
  # scp deploy@productionserver.com:~/yourapp_production.sql log/yourapp_production.sql 

  # psql -U gathitu -d yourapp_staging -f log/yourapp_staging.sql 
  # psql -U gathitu -d yourapp_production -f log/yourapp_production.sql 

  
  # desc "Symlink the database.yml file into latest release"
  # task :symlink do
  #   on roles :app do
  #     execute :sudo, "ln #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  #   end
  # end
  # after "deploy:updated", "postgresql:symlink"

  #   desc "database console"
  #   task :console do
  #     auth = capture "cat #{shared_path}/config/database.yml"
  #     puts "PASSWORD::: #{auth.match(/password: (.*$)/).captures.first}"
  #     hostname = find_servers_for_task(current_task).first
  #     exec "ssh #{hostname} -t 'source ~/.zshrc && psql -U #{application} #{pg_database}'"
  #   end

  #   namespace :local do
  #     desc "Download remote database to tmp/"
  #     task :download do
  #       dumpfile = "#{pg_local_dump_path}/#{pg_dump_file}.gz"
  #       get "#{pg_dump_path}/#{pg_dump_file}.gz", dumpfile
  #     end

  #     desc "Restores local database from temp file"
  #     task :restore do
  #       auth = YAML.load_file(File.expand_path('../../database.yml', __FILE__))
  #       dev  = auth['development']
  #       user, pass, database, host = dev['username'], dev['password'], dev['database'], dev['host']
  #       dumpfile = "#{pg_local_dump_path}/#{pg_dump_file}"
  #       system "gzip -cd #{dumpfile}.gz > #{dumpfile} && cat #{dumpfile} | psql -U #{user} -h #{host} #{database}"
  #     end

  #     desc "Dump remote database and download it locally"
  #     task :localize do
  #       remote.dump
  #       download
  #     end

  #     desc "Dump remote database, download it locally and restore local database"
  #     task :sync do
  #       localize
  #       restore
  #     end
  #   end

  #   namespace :remote do
  #     desc "Dump remote database"
  #     task :dump do
  #       dbyml = capture "cat #{shared_path}/config/database.yml"
  #       info  = YAML.load dbyml
  #       db    = info[stage.to_s]
  #       user, pass, database, host = db['username'], db['password'], db['database'], db['host']
  #       commands = <<-CMD
  #         pg_dump -U #{user} -h #{host} #{database} | \
  #         gzip > #{pg_dump_path}/#{pg_dump_file}.gz
  #       CMD
  #       run commands do |ch, stream, data|
  #         if data =~ /Password/
  #           ch.send_data("#{pass}\n")
  #         end
  #       end
  #     end

  #     desc "Uploads local sql.gz file to remote server"
  #     task :upload do
  #       dumpfile = "#{pg_local_dump_path}/#{pg_dump_file}.gz"
  #       upfile   = "#{pg_dump_path}/#{pg_dump_file}.gz"
  #       put File.read(dumpfile), upfile
  #     end

  #     desc "Restores remote database"
  #     task :restore do
  #       dumpfile = "#{pg_dump_path}/#{pg_dump_file}"
  #       gzfile   = "#{dumpfile}.gz"
  #       dbyml    = capture "cat #{shared_path}/config/database.yml"
  #       info     = YAML.load dbyml
  #       db       = info['production']
  #       user, pass, database, host = db['username'], db['password'], db['database'], db['host']

  #       commands = <<-CMD
  #         gzip -cd #{gzfile} > #{dumpfile} && \
  #         cat #{dumpfile} | \
  #         psql -U #{user} -h #{host} #{database}
  #       CMD

  #       run commands do |ch, stream, data|
  #         if data =~ /Password/
  #           ch.send_data("#{pass}\n")
  #         end
  #       end
  #     end

  #     desc "Uploads and restores remote database"
  #     task :sync do
  #       upload
  #       restore
  #     end
  #   end
end
