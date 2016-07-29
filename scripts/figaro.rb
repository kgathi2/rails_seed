append_to_file '.gitignore', '/config/application.yml' 
create_file 'config/application.yml' do <<-EOF
development:
  SECRET_KEY_BASE: 9c3c8e6bad188c6c028144dd2b5446941aca0c09d10b1676c4bc441ae7dd64efa90754b9abdd82faee1af37713b30b9e0241b3fb675aba2330a59cad57de4a97
  SIDEKIQ_USERNAME: username
  SIDEKIQ_PASSWORD: password
  # DOMAIN_NAME: localhost
  SMTP_ADDRESS: smtp.sendgrid.net
  SMTP_USERNAME: smtp_user
  SMTP_PASSWORD: smtp_password

test:
  SECRET_KEY_BASE: 9c3c8e6bad188c6c028144dd2b5446941aca0c09d10b1676c4bc441ae7dd64efa90754b9abdd82faee1af37713b30b9e0241b3fb675aba2330a59cad57de4a97
  SIDEKIQ_USERNAME: username
  SIDEKIQ_PASSWORD: password
  # DOMAIN_NAME: example.com
  SMTP_ADDRESS: smtp.sendgrid.net
  SMTP_USERNAME: smtp_user
  SMTP_PASSWORD: smtp_password

staging:
  SECRET_KEY_BASE: 9c3c8e6bad188c6c028144dd2b5446941aca0c09d10b1676c4bc441ae7dd64efa90754b9abdd82faee1af37713b30b9e0241b3fb675aba2330a59cad57de4a97
  SIDEKIQ_USERNAME: username
  SIDEKIQ_PASSWORD: password
  # DOMAIN_NAME: example.com
  SMTP_ADDRESS: smtp.sendgrid.net
  SMTP_USERNAME: smtp_user
  SMTP_PASSWORD: smtp_password

production:
  SECRET_KEY_BASE: 9c3c8e6bad188c6c028144dd2b5446941aca0c09d10b1676c4bc441ae7dd64efa90754b9abdd82faee1af37713b30b9e0241b3fb675aba2330a59cad57de4a97
  SIDEKIQ_USERNAME: username
  SIDEKIQ_PASSWORD: password
  # DOMAIN_NAME: example.com
  SMTP_ADDRESS: smtp.sendgrid.net
  SMTP_USERNAME: smtp_user
  SMTP_PASSWORD: smtp_password

EOF
end