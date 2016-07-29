# Rails setup to deployment in under 15Mins

Welcome to `rails_seed` Ruby on Rails application template! This is an all in one app with capistrano scripts to get you up and running on an new server in less than 15 Minutes. It installs, provisions and sets up the VPS as well as installing the default Rails application. Tested with Rails 5

My motivation for not using chef, puppet, ansible etc... was to keep things simple and familiar, reducing project dependencies and learning curve for getting set up. I encourage use of deploy tools if you really want the extra ummph!!! Any Rails app developer should be able to get a PRODUCTION READY system up in no time.

If you are new to rails application templates, take a look at [Rails Application Templates](http://guides.rubyonrails.org/rails_application_templates.html)

### Version 
Current < 0.1

## Getting Started

1. [Dependencies](https://github.com/kgathi2/rails_seed#dependencies)
2. [`rails_seed` stack](https://github.com/kgathi2/rails_seed#rails_seed-stack)
3. [VPS Preparation](https://github.com/kgathi2/rails_seed#vps-preparation)
4. [Repository Preparation](https://github.com/kgathi2/rails_seed#repository-preparation)
5. [Generate Rails Application](https://github.com/kgathi2/rails_seed#generate-rails-application)
6. [NOTE](https://github.com/kgathi2/rails_seed#note)
7. [Sample Superhero project(Optional)](https://github.com/kgathi2/rails_seed#sample-superhero-projectoptional)
8. [Issues](https://github.com/kgathi2/rails_seed#issues)
9. [Testing](https://github.com/kgathi2/rails_seed#testing)
10. [Todo](https://github.com/kgathi2/rails_seed#todo)
11. [Contributing](https://github.com/kgathi2/rails_seed#contributing)
12. [License](https://github.com/kgathi2/rails_seed#license)

## Dependencies

1. Clean, Fresh Linux Server. Whip one up quick on [Linode](http://linode.com), [Digital Ocean](http://digitalocean.com), [AWS](http://aws.amazon.com) etc... Preferably Ubuntu > 14.04. Should work on other debian distros that use `apt-get` package manager.
2. Local Machine that can run `$ rails new [app]` command. Template has been tested with MacOX but should also work well if you are on a Linux Machine. Good luck with Windows
3. 15 Minutes to spare
4. Glass of [Madafu](http://1.bp.blogspot.com/-MAqnCnoyskI/VeGZj6E4OmI/AAAAAAAAG_M/sCJISvVwq60/w1200-h630-p-nu/Madafu.jpg). Stimulates awesomeness!

## `rails_seed` stack

The template installs the the latest versions of following packages on your server

1. git
2. Ruby
3. Nginx
4. Postgresql
5. Memcached
6. Redis
7. Security - ufw (Uncomplicated FireWall), Fail2Ban, intrusion detection, logwatch
8. Nodejs
9. Some essential stuff (postfix,curl,htop,less,wget,imagemagick)
10. mosh (mobile shell)
11. git-flow for your project
12. Sets up swap memory (You need this especially if RAM is less than 1GB)

Before we setup a project, we need to prepare our Server (VPS) and git deployment repository

## VPS Preparation
On a brand new VPS, or Vagrant run the following script below. It basically creates a deploy user and uploads a public key for access into the server from your machine. Please generate and use you public key instead from `~/.ssh/id_rsa.pub`. Copy it quicky on your clipboard with `$ cat ~/.ssh/id_rsa.pub | pbcopy # MacOs`, or set up a new one [How To Set Up SSH Keys](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2)

You can set up the following as a Linode stackscript or digital ocean userdata and is compatible with [`cloud init`](https://cloudinit.readthedocs.io/en/latest/topics/format.html) as well.
Replace [SSH_KEY] with your key
```bash
#!/bin/bash
DEPLOY_USER="deploy"
groupadd admin
sudo useradd $DEPLOY_USER -g admin -m -s /bin/bash
echo "$DEPLOY_USER user created successfully"

PUBKEY='SSH_KEY'

#Add deploy user ssh_key
cd /home/deploy
sudo mkdir -p .ssh
sudo echo $PUBKEY >> .ssh/authorized_keys
sudo chmod 700 .ssh
sudo chmod 600 .ssh/authorized_keys
sudo chown -R deploy:admin .ssh
sudo echo '%admin ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
sudo usermod -p '!' root

```
For [`cloud init`](https://cloudinit.readthedocs.io/en/latest/topics/examples.html#yaml-examples) configurations, which i prefer (like in digital ocean [userdata](https://www.digitalocean.com/community/tutorials/an-introduction-to-droplet-metadata)). However note that some older version of linux and some distros do not support `cloud init`
```yml
#cloud-config
users:
  - name: deploy
    ssh-authorized-keys:
      - SSH_KEY
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/bash
runcmd:
  - sudo usermod -p '!' root
```
## Repository Preparation 

You need to set up the new repo that you will be working and deploying from. You can use a bitbucket, github or any other repo you are familiar with. Once done, you'll need the git address like below
```bash
git@bitbucket.org:your_username/your_repo.git
```  
Great. We are now ready to go.

## Generate Rails Application
Run the following command to generate a rails application with this template. Normal flags work, i.e --api, -B etc...
```console
$ rails new [APP_NAME] -m https://goo.gl/AMZ2J7 -d postgresql
```
which is equivalent to 
```console
$ rails new [APP_NAME] -m https://raw.github.com/kgathi2/rails_seed/master/rails_seed.rb -d postgresql
```

Follow the few prompts and you'll have a ready to deploy app shortly. If you decide not to bundle (-B) after the app is generated, it's important that `gem install capistrano` and `gem install guard` are set up on your local machine

Then once done the generator will prompt you to configure your application to your preferences as well as your staging and production server IP in `config/deploy/[stage].rb`
In the simplest case, replace the following lines
```ruby
# server 'example.com', user: 'deploy', roles: %w{app db web}, my_property: :my_value

# replace the above line with

server 'MY_SERVER_IP', user: 'deploy', roles: %w{app db web}, my_property: :my_value
```
There after the next couple of tasks will get you live. Run the following when when prompted. Make sure you are in the project directory i.e. `cd APP_NAME`.

1. Run the provisioning task (approx 5 min)
```console
$ cap [stage] provision
```
2. Run the set up script (approx 1 min)
```console
$ cap [stage] setup
``` 
3. Run the deploy script (approx 2 min)
```console
$ cap [stage] deploy
```

You may want to prefix the commands with `bundle exec` just incase you have conflicting gems in your local machine. You'll notice that the first `$ cap [stage] deploy` deployment takes longer than subsequent ones due to initial bundling of gems in the server.

## Note
This script sets up the following

1. Nginx, SSL and Puma with zero downtime. You can replace the SSL key and self signed certificate with your own set in `lib/capistrano/templates/localhost.key` and `lib/capistrano/templates/localhost.crt`
2. git-flow
3. sidekiq for background jobs
4. sidekiq web on `[your_server_ip]/queue` with http_basic authentiation. Credentials are configured in `config\application.yml`
5. Figaro for environmental variables. Need to be configured before running `$ cap [stage] deploy`. Configurations are in `config\application.yml`
6. Sets up Action Mailer in `app/application.rb` and credentials in `config\application.yml`
7. In `app/application.rb`, it sets up config object for application version `Rails.config.version` depending on your git commit version number. It basically reads the git commit message and pick out the version number
8. Asset syncing via rsync capistrano tasks. Assets are ignored in the git repo. To sync assets, run `$ cap [stage] deploy:assets_compile`
9. After provisioning, a deploy key is generated for your repo.
10. Uses Capistrano 3 
11. Uses [`guard`](https://github.com/guard/guard), a must have, if you want to build unbreakable, bullet proof applications. Can be disabled if you are on this [List of 15 of the world’s best living programmers](http://www.itworld.com/article/2823547/enterprise-software/158256-superclass-14-of-the-world-s-best-living-programmers.html#slide16) or this [List of most famous Software developers](http://goo.gl/cB6svs). If so, then just comment out the testing gems.
11. Run `$ cap -T` to view all tasks available
12. Uses rack middleware, [`rack-attack`](https://github.com/kickstarter/rack-attack).


If all went well, you should browse to your ip address and see a 404 error for page not found. Awesome! Now get coding to put your app on there! There is also a route `\queue` that will take you to your sidekiq web application.  
## Sample Superhero project (Optional)
Our superheros deserve an online platform to connect.
After successful `cap [STAGE] setup` run the following
```console
$ rails g scaffold superhero name:string powers:text
$ rake db:migrate
```
Make superheros the landing page in `config/routes.rb`
```ruby
# in config/routes.rb
root 'superheros#index'
```
Commit changes and push to repo
```console
$ git add .
$ git commit -m 'Superheros V 0.0.01 Added Super Heros'
$ git push -u origin --all
```
Deploy
```console
$ cap [STAGE] deploy
$ cap [STAGE] deploy:assets_compile
```
You should see your superhero app on your IP address

## Issues
If all did not go well, you can retry the commands and pinpoint which capisrano tasks failed. In your generated app, look at `lib/capistrano/settings.rb`, `lib/capistrano/provision.rb`, `lib/capistrano/setup.rb` and `lib/capistrano/deploy.rb`

A Sidekiq web [Issue](https://github.com/mperham/sidekiq/issues/2839) requires the latest master branch of sinatra. This is still unstable and may break the deployed app. If so, try the following 
```ruby
# Gemfile
gem "rack-protection", github: "sinatra/rack-protection"
```

You may want to prefix the commands with `bundle exec` just incase you have conflicting gems in your local machine i.e. `$ bundle exec cap [STAGE] provision`

If after successful deploying you get a 503, this is the rack middleware intercepting the request. It protects against bad guys like proxy phising etc.. on the application level. Take a look at the `config/initializers/rack_attack.rb` initializer and customise to your liking

If any other issue, create a new issue and i'll see what's up.

## Testing
Testing has been done on a 512MB digital ocean droplet on

1. Ubuntu 14.04
2. Rails 5

## Todo

1. Test with Rails 4
2. Test with other linux distros (FreeBSD, Fedora, Debian, CoreOs, Centos)
3. Test with Linux and Windows local machines

## Contributing

1. Fork it (https://github.com/[my-github-username]/rails_seed/fork)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
Create a new Pull Request

## License

Copyright Kariuki Gathitu

Released under an MIT License.
