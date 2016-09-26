# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.
set :stage, :production
set :branch, 'develop'

set :rails_env, 'production'
#
# app1 - app1.mybyteapp.com
# app2 - app2.mybyteapp.com
# db   - db.mybyteapp.com
#

role :app, %w{deploy@45.55.211.26}
role :web, %w{deploy@45.55.211.26}
role :db,  %w{deploy@45.55.211.26}

set :deploy_to, '/var/www/MyMenu-Server'

role :resque_worker, %w{deploy@45.55.211.26}
role :resque_scheduler, %w{deploy@45.55.211.26}

set :workers, { "shared_menu" => 2 }
# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

#server 'app.mybyteapp.com', user: 'deploy', roles: %w(web app db)


# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------

 set :ssh_options, {
   keys: %w(~/.ssh/id_rsa),
   forward_agent: true,
   auth_methods: %w(publickey),
   port: 5655
 }
#
# And/or per server (overrides global)
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
