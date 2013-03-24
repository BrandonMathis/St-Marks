load 'deploy/assets'
require 'bundler/capistrano'

set :default_environment, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

set :application, "stmarks"
set :repository,  "git://github.com/BrandonMathis/St-Marks.git"
set :use_sudo, false

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "50.116.34.76"                          # Your HTTP server, Apache/etc
role :app, "50.116.34.76"                          # This may be the same as your `Web` server
role :db,  "50.116.34.76", :primary => true # This is where Rails migrations will run

set :user, "deploy"
set :ssh_options, { :forward_agent => true }

default_run_options[:pty] = true

set :deploy_to, '/var/www/stmarks'
set :deploy_via, :remote_cache
set :copy_cache, true
set :copy_exclude, [".git"]
set :copy_compression, :bz2

set :scm, :git
set :scm_verbose, true
set(:current_branch) { `git branch`.match(/\* (\S+)\s/m)[1] || raise("Couldn't determine current branch") }
set :branch, defer { current_branch }

after 'deploy:finalize_update', 'deploy:make_links'

namespace :deploy do
  desc 'Symlinks the database.yml'
  task :make_links, roles: :app do
    run "ln -nfs #{shared_path}/database.yml #{release_path}/config/database.yml"
  end
end

after "deploy:restart", "deploy:cleanup"

set :rails_env, :production
set :unicorn_binary, "bundle exec unicorn"
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do 
    run "cd #{current_path} && #{unicorn_binary} -c #{unicorn_config} -E #{rails_env} -D"
  end
  task :stop, :roles => :app, :except => { :no_release => true } do 
    run "kill `cat #{unicorn_pid}`"
  end
  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    run "kill -s QUIT `cat #{unicorn_pid}`"
  end
  task :reload, :roles => :app, :except => { :no_release => true } do
    run "kill -s USR2 `cat #{unicorn_pid}`"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    # stop
    # start
  end
end
