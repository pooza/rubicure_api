port 3013
daemonize true

dir = File.expand_path(File.dirname(File.dirname(__FILE__)))
pidfile File.join(dir, 'tmp/pids/puma.pid')
