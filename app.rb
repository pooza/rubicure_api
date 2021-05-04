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

class App < Sinatra::Base
  use Rollbar::Middleware::Sinatra

  set :json_content_type, 'application/json; charset=UTF-8'

  configure do
    mime_type :ics, 'text/calendar'
  end

  get '/' do
    @girls = Precure.all
    @series = Precure.map(&:itself)
    @date_girls = girl_birthdays(Date.today.year, Date.today.year + 1).select do |date, _|
      Date.today <= date && date <= Date.today + 120
    end
    @date_casts = cast_birthdays(Date.today.year, Date.today.year + 1).select do |date, _|
      Date.today <= date && date <= Date.today + 120
    end
    @livecure_dates = livecure_dates
    slim :index
  end

  get '/series.json' do # deprecated
    redirect '/v2/series.json'
  end

  get '/series/:name.json' do # deprecated
    redirect "/v2/series/#{params[:name]}.json"
  end

  get '/girls.json' do # deprecated
    redirect '/v2/girls.json'
  end

  get '/girls/:name.json' do # deprecated
    redirect "/v2/girls/#{params[:name]}.json"
  end

  get '/girls/birthday.ics' do # deprecated
    redirect '/v2/birthday/girls.ics'
  end

  get '/v2/series.json' do
    json Precure.map(&:to_h)
  end

  get '/v2/series/:name.json' do
    name = params[:name].to_sym
    halt 404 unless Rubicure::Series.valid?(name)
    json Rubicure::Series.find(name).to_h
  end

  get '/v2/girls.json' do
    json Precure.all.map(&:to_h)
  end

  get '/v2/girls/:name.json' do
    name = params[:name].to_sym
    halt 404 unless Rubicure::Girl.valid?(name)
    json Rubicure::Girl.find(name).to_h
  end

  get '/v2/livecure.json' do
    json livecure_dates
  end

  get '/v2/birthday/girls.ics' do
    content_type :ics
    girls_ical(girl_birthdays(Date.today.year, Date.today.year + 2))
  end

  get '/v2/birthday/girls.json' do
    json girl_birthdays(Date.today.year, Date.today.year + 2)
  end

  get '/v2/birthday/casts.ics' do
    content_type :ics
    casts_ical(cast_birthdays(Date.today.year, Date.today.year + 2))
  end

  get '/v2/birthday/casts.json' do
    json cast_birthdays(Date.today.year, Date.today.year + 2)
  end

  before do
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
      girls = {}
      Precure.all.select(&:have_birthday?).each do |girl|
        (from_year..to_year).each do |year|
          girls[Date.parse("#{year}/#{girl.birthday}")] = girl
        end
      end
      return girls.sort.to_h
    end

    def cast_birthdays(from_year, to_year)
      casts = {}
      Precure.all.select(&:have_cast_birthday?).each do |girl|
        (from_year..to_year).each do |year|
          casts[Date.parse("#{year}/#{girl.cast_birthday}")] = girl
        end
      end
      return casts.sort.to_h
    end

    def livecure_dates
      today = Date.today
      year = today.year
      return girl_birthdays(year, year + 1)
        .select {|d, _| today <= d && d <= today + 60}
        .select {|_, g| g.have_birthday?}
        .merge(
          cast_birthdays(year, year + 1)
            .select {|d, _| today <= d && d <= today + 60}
            .select {|_, g| !g.have_birthday? && g.have_cast_birthday?}
        )
        .sort
        .map {|d, g| [d, g.merge(type: g.have_birthday? ? 'precure' : 'cast')]}
        .to_h
    end

    def girls_ical(girls)
      cal = Icalendar::Calendar.new
      cal.append_custom_property('X-WR-CALNAME;VALUE=TEXT', 'プリキュアの誕生日')
      girls.each do |date, girl|
        cal.event do |e|
          e.summary = "#{girl.human_name}（#{girl.precure_name}）の誕生日"
          e.dtstart = Icalendar::Values::Date.new(date)
        end
      end
      cal.publish
      return cal.to_ical
    end

    def casts_ical(girls)
      cal = Icalendar::Calendar.new
      cal.append_custom_property('X-WR-CALNAME;VALUE=TEXT', 'キャストの誕生日')
      girls.each do |date, girl|
        cal.event do |e|
          e.summary = "#{girl.cast_name}（#{girl.precure_name}）の誕生日"
          e.dtstart = Icalendar::Values::Date.new(date)
        end
      end
      cal.publish
      return cal.to_ical
    end

    def week_class(time)
      date = time.to_date
      return 'danger' if HolidayJp.holiday?(date) || date.sunday?
      return 'info' if date.saturday?
      return nil
    end
  end
end
