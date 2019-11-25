source "https://rubygems.org"
git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

ruby "2.6.5"

gem "activesupport"
gem "holiday_jp"
gem "icalendar"
gem "puma"
gem "puma-heroku"
gem "rollbar"
gem "rubicure", git: "https://github.com/pooza/rubicure.git", :branch => "master.pooza"
gem "sinatra"
gem "sinatra-contrib"
gem "slim"
gem "syslog-logger"

group :development do
  gem "foreman", require: false

  # TODO: Remove after https://github.com/onk/onkcop/pull/62 and https://github.com/onk/onkcop/pull/63 are merged
  # gem "onkcop", ">= 0.53.0.3", require: false
  gem "onkcop", require: false, github: "sue445/onkcop", branch: "rubocop_0.72.0"

  gem "rake", require: false
  gem "rubocop-performance", require: false
end

group :test do
  gem "rack-test"
  gem "test-unit"
  gem "timecop"
end
