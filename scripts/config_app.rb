environment nil, env: 'development' do <<-RUBY 
	config.debug_exception_response_format = :default
	config.action_mailer.delivery_method = :letter_opener
	config.action_mailer.default_url_options = { :host => 'localhost', port:3000 }
	config.action_mailer.asset_host = 'http://localhost:3000'
RUBY
end

environment nil, env: 'test' do <<-RUBY 
	config.action_mailer.asset_host = nil
RUBY
end


application do <<-RUBY

		config.time_zone = 'Nairobi'
		# App version from git commit message. Message must contain versioning major.minor.fix e.g 0.2.31
		config.version = {
			master: (`git --no-pager log master -1 --pretty=%B`.presence || `cd ../repo && git --no-pager log master -1 --pretty=%B`.presence rescue ''),
			develop: (`git --no-pager log develop -1 --pretty=%B`.presence || `cd ../repo && git --no-pager log develop -1 --pretty=%B`.presence rescue '')
		}
		config.version_no = {
			master: (config.version[:master].scan(/\d+\.\d+\.\d+/).first rescue ''),
			develop: (config.version[:develop].scan(/\d+\.\d+\.\d+/).first rescue '')
		}

		# ActionMailer Config
		config.action_mailer.default_url_options = { host: ENV['DOMAIN_NAME'] }
		config.action_mailer.perform_deliveries = true
		config.action_mailer.raise_delivery_errors = true
		config.action_mailer.asset_host = ['https://', ENV['DOMAIN_NAME']].join

		config.action_mailer.smtp_settings = {
			address: ENV['SMTP_ADDRESS'],
			port: 587,
			domain: ENV['DOMAIN_NAME'],
			authentication: "plain",
			enable_starttls_auto: true,
			user_name: ENV['SMTP_USERNAME'],
			password: ENV['SMTP_PASSWORD']
		}

	RUBY
end