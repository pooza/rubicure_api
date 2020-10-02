source "https://rubygems.org"
git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

ruby ">= 2.5.7"

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
  # TODO: Remove after following PR are merged
  # * https://github.com/onk/onkcop/pull/62
  # * https://github.com/onk/onkcop/pull/63
  # * https://github.com/onk/onkcop/pull/65
  # gem "onkcop", ">= 0.53.0.3", require: false
  gem "onkcop", require: false, github: "sue445/onkcop", branch: "develop"
  gem "rubocop-performance", require: false
end

group :test do
  gem "rack-test"
  gem "rubydoctest"
  gem "test-unit"
  gem "timecop"
end
