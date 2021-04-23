require 'sinatra'
require 'sinatra/json'
require 'slim'
require 'yaml'
require 'active_support/all'
require 'rollbar/middleware/sinatra'
require 'rubicure'
require 'icalendar'
require 'date'
require 'holiday_jp'
require 'syslog/logger'

class Object
  def to_pretty_json
    JSON.pretty_generate(self)
  end
end

class App < Sinatra::Base
  use Rollbar::Middleware::Sinatra

  set :json_content_type, 'application/json; charset=UTF-8'

  configure do
    mime_type :ics, 'text/calendar'
  end

  get '/' do
    @girls = Precure.all
    @series = Precure.map(&:itself)

    date_girls = girl_birthdays(Date.today.year, Date.today.year + 1)
    @date_girls = date_girls.select {|date, _| Date.today <= date && date <= Date.today + 120}

    date_casts = cast_birthdays(Date.today.year, Date.today.year + 1)
    @date_casts = date_casts.select {|date, _| Date.today <= date && date <= Date.today + 120}

    slim :index
  end

  get '/series.json' do
    # convert to plain Hash
    all_series = Precure.map(&:to_h)

    json all_series, @json_options
  end

  get '/series/:name.json' do
    name = params[:name].to_sym
    halt 404 unless Rubicure::Series.valid?(name)

    series = Rubicure::Series.find(name)

    # convert to plain Hash
    json series.to_h, @json_options
  end

  get '/girls.json' do
    # convert to plain Hash
    girls = Precure.all.map(&:to_h)

    json girls, @json_options
  end

  get '/girls/:name.json' do
    name = params[:name].to_sym
    halt 404 unless Rubicure::Girl.valid?(name)

    girl = Rubicure::Girl.find(name)

    # convert to plain Hash
    json girl.to_h, @json_options
  end

  get '/girls/birthday.ics' do
    content_type :ics
    girls_ical(girl_birthdays(Date.today.year, Date.today.year + 2))
  end

  get '/casts/birthday.ics' do
    content_type :ics
    casts_ical(cast_birthdays(Date.today.year, Date.today.year + 2))
  end

  before do
    @json_options = {}
    @json_options[:json_encoder] = :to_pretty_json if params[:format] == 'pretty'
    @logger = Syslog::Logger.new('rubicure_api')
  end

  after do
    @logger.info({request: {path: request.path, params: @params}})
  end

  error do |e|
    @logger.error({class: e.class, message: e.message})
  end

  helpers do # rubocop:disable Metrics/BlockLength
    def girl_birthdays(from_year, to_year)
      date_girls = {}
      girls = Precure.all.select(&:have_birthday?)

      girls.each do |girl|
        (from_year..to_year).each do |year|
          date = Date.parse("#{year}/#{girl.birthday}")
          date_girls[date] = girl
        end
      end

      date_girls.sort.to_h
    end

    def cast_birthdays(from_year, to_year)
      date_casts = {}
      girls = Precure.all.select(&:have_cast_birthday?)

      girls.each do |girl|
        (from_year..to_year).each do |year|
          date = Date.parse("#{year}/#{girl.cast_birthday}")
          date_casts[date] = girl
        end
      end

      date_casts.sort.to_h
    end

    def girls_ical(date_girls)
      cal = Icalendar::Calendar.new

      cal.append_custom_property('X-WR-CALNAME;VALUE=TEXT', 'プリキュアの誕生日')

      date_girls.each do |date, girl|
        cal.event do |e|
          e.summary = "#{girl.human_name}（#{girl.precure_name}）の誕生日"
          e.dtstart = Icalendar::Values::Date.new(date)
        end
      end

      cal.publish
      cal.to_ical
    end

    def casts_ical(date_girls)
      cal = Icalendar::Calendar.new

      cal.append_custom_property('X-WR-CALNAME;VALUE=TEXT', 'キャストの誕生日')

      date_girls.each do |date, girl|
        cal.event do |e|
          e.summary = "#{girl.cast_name}（#{girl.precure_name}）の誕生日"
          e.dtstart = Icalendar::Values::Date.new(date)
        end
      end

      cal.publish
      cal.to_ical
    end

    def week_class(time)
      date = time.to_date

      if HolidayJp.holiday?(date) || date.sunday?
        # red
        'danger'
      elsif date.saturday?
        # blue
        'info'
      end
    end
  end
end
