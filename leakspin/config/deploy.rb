set :application, "leakspin"
set :deploy_via, :remote_cache
set :user, 'alex'
set :runner, user

set :scm, :git
set :repository, "git@github.com:alx/#{application}.git"
set :branch, 'master'
set :git_enable_submodules, 1
set :keep_releases, 3
set :deploy_to, "/var/www/apps/#{application}"

server "leakspin.tetalab.org", :web, :app, :db, :primary => true