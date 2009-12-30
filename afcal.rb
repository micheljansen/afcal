require 'rubygems'
require 'sinatra'
require 'time'
require 'logger'

require 'lib/cache'
require 'lib/twente_milieu_data'

# the full url where this app will be installed.
BASE_URL = 'http://afcal.micheljansen.org'

# add caching to Sinatra
# class Sinatra::Event
#   include CacheableEvent
# end

configure do 
  CONFIG = {}
end

configure :development do
  LOGGER = Logger.new(STDOUT)
  CONFIG['memcached'] = 'localhost:11211'
end

configure :production do
  LOGGER = Logger.new("log/sinatra.production.log")
  CONFIG['memcached'] = 'localhost:11211'
end
 
helpers do
  def logger
    LOGGER
  end
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  erb :index
end

get '/:postalcode/:housenumber/all.:format' do

  #sanitize parameters
  raise "no postal code provided" if params[:postalcode].nil? 
  @postalcode = params[:postalcode].gsub(/[^a-z|^0-9]/i, "")[0..5]
  
  raise "no house number provided" if params[:housenumber].nil?
  @housenumber = params[:housenumber].to_i
  
  time = Time.parse(params[:time]) if params[:time] && params[:time] != ""
  alarm = params[:alarm].to_i if params[:alarm]
  
  #fetch events
  @all_events = Sinatra::Cache.cache("#{params[:postalcode]}/#{params[:housenumber]}/#{time}", :expire => 60*60*24) do
    TwenteMilieuData.new(params[:postalcode], params[:housenumber], time).all_events
  end
  
  case params[:format]
  when "ics"
    content_type 'text/calendar'
    icalendar = @all_events.to_icalendar
    
    if alarm
      icalendar.events.each do |event|
        event.alarm do 
          action        "DISPLAY" # This line isn't necessary, it's the default
          summary       "Alarm"
          trigger       "-PT#{alarm}M" #
        end
      end
    end
    
    icalendar.to_ical
  else
    erb :calendar
  end
end
