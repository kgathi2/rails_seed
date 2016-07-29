inside 'config' do
  template "environments/production.rb", "environments/staging.rb"
  gsub_file "database.yml", "#{app_name.upcase}_DATABASE_PASSWORD","DB_PASSWORD"
  comment_lines "database.yml", /username/
  append_to_file 'database.yml' do <<-EOF

staging:
  <<: *default
  database: #{app_name}_staging
  # username: #{app_name}
  password: <%= ENV['DB_PASSWORD'] %>

EOF
  end
end