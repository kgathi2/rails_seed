namespace :postfix do
  %w(start stop restart reload flush check abort force-reload status).each do |command|
    desc "#{command} postfix"
    task command do
      on roles (:all) do
        execute :sudo, "service postfix #{command}"
      end
    end
  end
end
