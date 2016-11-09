# config valid only for Capistrano 3.1
require 'bugsnag/capistrano'
require "whenever/capistrano"

lock '3.2.1'

set :application, 'MyMenu-Server'
set :repo_url, 'git@github.com:MyMenu/MyMenu-Server.git'
set :rvm_ruby_version, '2.1.2'
# https://github.com/MyMenu/MyMenu-Server.git
# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

set :stages, ["staging_bugs", "staging", "production"]
set :default_stage, "staging"

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/application.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 1

# BugSnag Integration
set :bugsnag_api_key, 'e19c64acabbba4e1ceaad7f45ea3e9f8'

set :whenever_command, "bundle exec whenever"

namespace :figaro do
  desc "SCP transfer figaro configuration to the shared folder"
  task :upload do
    on roles(:app) do
      upload! StringIO.new(File.read("config/application.yml")), "#{shared_path}/config/application.yml"
    end
  end
end

namespace :unicorn do
  desc "Start unicorn"
  task :start do
    on roles(:app) do
      execute 'sudo service unicorn start'
    end
  end

  desc "Stop unicorn"
  task :stop do
    on roles(:app) do
      execute 'sudo service unicorn stop'
    end
  end

  task :restart do
    on roles(:app) do
      execute 'sudo service unicorn restart'
    end
  end
end

namespace :redis do
  %i(start stop restart).each do |command|
    desc "#{command} redis"
    task command do
      on roles(:app) do
        run "#{sudo} service redis-server #{command}"
      end
    end
  end
end

namespace :migration do
  task :migrate do
    run "cd /var/www/MultiplyMeApi/current; bundle exec rake db:migrate RAILS_ENV=production"
  end
end

# after :deploy, 'figaro:setup'
# after :deploy, 'figaro:finalize'
# after :deploy, 'redis:restart'
after :deploy, 'deploy:finished'
after :deploy, 'sidekiq:restart'

namespace :deploy do

  desc "Bundle"
  task :binstub do
    on roles(:app) do
      execute "cd /var/www/MultiplyMeApi/current; bundle --binstubs"
    end
  end

  desc 'after deploy'
  task :finished do
    #invoke 'deploy:binstub'
    #invoke 'unicorn:start'
    invoke 'resque:restart'
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      within release_path do
         execute :rake, 'tmp:clear'
      end
    end
  end

end
