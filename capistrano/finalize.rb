# awk '{gsub(/pattern/,"repla\'cement\"")}' Capfile

# required = "/my/directory/path"
# sed_command = "sed 's/^some_key.*$/#{directory}/' shell_script.sh > shell_script_with_qa_variables.sh"
# run sed_command

# # git@bitbucket.org:kgathi2/blank.git
# sed -i '.bak' 's/require\s+["']capistrano\/rvm["'].*$/ dsdsdsds/g' Capfile

# awk '{gsub(/pattern/,"replacement")}' Capfile
# awk '{gsub( /require\s+["\']capistrano\/rvm["\'].*$/,"replacement")}' Capfile

# uncomment_lines "Capfile", /require\s+["']capistrano\/rvm["'].*$/

# gsub_file "Capfile", /require\s+["']capistrano\/rvm["'].*$/,'require \'rvm1/capistrano3\''
# uncomment_lines 'Capfile', /rvm1\/capistrano3/

append_to_file '.gitignore' do <<-EOF

#Ignore all Redis dumps
/*.rdb

#Bowers componets 
/lib/assets/bower_components/*
/vendor/assets/bower_components/*
.DS_Store 

/vendor/assets/bower_components

# Public assest. Use asset syncing to depoy the assets instead on keeping them in the repo
/public/assets/

# Ignore Doc files
/doc/*

	EOF
end

git :init
git add: "."
git commit: %Q{ -m '#{app_name} Version 0.0.00 Initial commit' }
git flow: "init -d"
git remote: "add origin #{@repo}"
git push: "-u origin --all" # pushes up the repo and its refs for the first time
git push: "origin --tags" # pushes up any tags