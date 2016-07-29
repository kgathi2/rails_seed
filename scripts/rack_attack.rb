application 'config.middleware.use Rack::Attack'
initializer 'rack_attack.rb', <<-RUBY
class Rack::Attack
 	# Always allow requests from localhost
	# (blacklist & throttles are skipped)
	Rack::Attack.whitelist('allow from localhost') do |req|
	  # Requests are allowed if the return value is truthy
	  %w(
	  	127.0.0.1 
	  	::1
	  	).include?(req.ip)
	end

	# Block requests from any domain that is not allowed like billiga-slipsar.se
	Rack::Attack.blacklist('Allow Domains only') do |req|
	  # Requests are blocked if the return value is truthy
	  ENV['DOMAIN_NAME'].present? ?
		[ENV['DOMAIN_NAME']].exclude?(req.host) :
		false
	end

	Rack::Attack.blacklisted_response = lambda do |env|
	  # Using 503 because it may make attacker think that they have successfully
	  # DOSed the site. Rack::Attack returns 403 for blacklists by default
	  [ 503, {}, ['']]
	end

end
RUBY
