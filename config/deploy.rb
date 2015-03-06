# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'my_app_name'
set :repo_url, 'https://github.com/minimum2scp/railstest01.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/railstest01'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/secrets.yml .env}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'unicorn:legacy_restart'
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  {
    "secrets" => "config/secrets.yml",
    "database_yml" => "config/database.yml",
  }.each do |name, local_path|
    desc "upload #{local_path}"
    task :"upload_#{name}" => [:set_rails_env] do
      on roles(:app) do |host|
        info "upload #{local_path}"
        remote_path = File.expand_path(local_path, shared_path)
        remote_path.sub!(".example", "")
        dir = File.dirname(remote_path)
        if test "[ ! -d #{dir} ]"
          execute "mkdir -p #{dir}"
        end
        upload!(local_path, remote_path)
      end
    end
  end

  desc "upload .env"
  task :"upload_dotenv" do
    local_path = "config/deploy/#{fetch(:stage)}.env"
    remote_path = File.expand_path(".env", shared_path)
    on roles(:app) do |host|
      info "upload #{local_path} to #{remote_path}"
      dir = File.dirname(remote_path)
      if test "[ ! -d #{dir} ]"
        execute "mkdir -p #{dir}"
      end
      upload!(local_path, remote_path)
    end
  end
end

set :rbenv_type, :system # :system or :user
set :rbenv_path, '/opt/rbenv'
set :rbenv_ruby, '2.1.5'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value

#set :bundle_flags, '--quiet'
#set :bundle_path, nil
#set :bundle_binstubs, nil

set :unicorn_pid, "#{shared_path}/tmp/pids/unicorn.pid"
set :unicorn_config_path, -> { File.join(current_path, "config", "unicorn.rb") }

