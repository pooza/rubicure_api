source "https://rubygems.org"
git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

ruby "~> 2.7.0"

gem "activesupport"
gem "holiday_jp"
gem "icalendar"
gem "puma", "<5"
gem "rake"
gem "rollbar"
gem "rubicure", github: "pooza/rubicure", branch: "master.pooza"
gem "sinatra"
gem "sinatra-contrib"
gem "slim"
gem "syslog-logger"

group :development do
  gem "rubocop-performance", require: false
  gem "rubocop-rake"
end

group :test do
  gem "rack-test"
  gem "rubydoctest"
  gem "test-unit"
  gem "timecop"
end
