APP_DIR = File.expand_path(__dir__).freeze
$LOAD_PATH.unshift(File.join(APP_DIR, 'app/lib'))
ENV['BUNDLE_GEMFILE'] ||= File.join(APP_DIR, 'Gemfile')

require 'bundler/setup'

desc 'test'
task :test do
  Dir.glob(File.join(APP_DIR, 'test/*.rb')).sort.each do |f|
    require f
  end
end

desc 'lint'
task :lint do
  sh 'bundle exec rubocop'
end

desc 'start'
task :start do
  sh 'puma'
end

desc 'stop'
task :stop do
  Process.kill('TERM', File.read(File.join(APP_DIR, 'tmp/pids/puma.pid')).to_i)
rescue => e
  warn e.message
  exit 1
end

desc 'restart'
task restart: [:stop, :start]
