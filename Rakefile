require "rake/testtask"
dir = File.expand_path(__dir__)

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/*_test.rb"]
  t.verbose = true
  t.warning = false
end

task :default => "test"

desc 'start'
task :start do
  sh 'bundle exec puma'
end

desc 'stop'
task :stop do
  Process.kill('TERM', File.read(File.join(dir, 'tmp/pids/puma.pid')).to_i) rescue nil
end

desc 'restart'
task :restart => [:stop, :start]
