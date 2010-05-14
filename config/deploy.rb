default_run_options[:pty] = true

set :application, 'storyboardr'

set :scm,         :git
set :repository,  'git@github.com:theworkinggroup/storyboardr.git'
set :deploy_via,  :remote_cache

set :user,      'deploy'
set :use_sudo,  false

set :keep_releases, 5


task :production do
  set :rails_env, 'production'
  set :domain,    'rails2.twg.ca'
  set :deploy_to, "/web/#{application}"
  set :branch,    'master'
  set :keep_releases, 5
  
  role :web,  domain
  role :app,  domain
  role :db,   domain, :primary => true
end

namespace :deploy do
  
  task :start do ; end
  task :stop  do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{release_path}/tmp/restart.txt"
  end
  
end

after 'deploy', 'deploy:cleanup'