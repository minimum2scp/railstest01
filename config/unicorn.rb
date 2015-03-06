rails_root = File.expand_path("../..", __FILE__)

# Number of worker process
worker_processes 3

# listen "#{rails_root}/tmp/unicorn.sock", :backlog => 64
# listen 8080 # , :tcp_nopush
listen "#{rails_root}/tmp/sockets/unicorn.sock"

# 60 seconds (the default)
# timeout 30

pid "#{rails_root}/tmp/pids/unicorn.pid"

# By default, the Unicorn Logger will write to stderr.
stderr_path "#{rails_root}/log/unicorn_stderr.log"
stdout_path "#{rails_root}/log/unicorn_stdout.log"

# save memory
preload_app true

before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = "/var/www/railstest01/current/Gemfile"
end

before_fork do |server, worker|
  # Disconnect since the database connection will not carry over
  if defined? ActiveRecord::Base
    ActiveRecord::Base.connection.disconnect!
  end
end

after_fork do |server, worker|
  # Start up the database connection again in the worker
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end

