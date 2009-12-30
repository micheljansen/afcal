require 'rubygems'
require 'sinatra'
require 'time'
require 'logger'
require 'cgi'

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
  LOGGER = Logger.new("log/sinatra.log")
  CONFIG['memcached'] = 'localhost:11211'
end
 
helpers do
  def logger
    LOGGER
  end
  
  def extract_postalcode(param)
    param.to_s.gsub(/[^a-z|^0-9]/i, "")[0..5]
  end
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  @postalcode = params[:postalcode] ? extract_postalcode(params[:postalcode]) : ""
  @homenumber = params[:homenumber] ? params[:homenumber].to_i : ""
  @allday = params[:allday] == "0" ? false : true
  @time = params[:time] ? params[:time] : ""
  @alarm = params[:alarm]
  
  @generated_url = "#{BASE_URL}/#{@postalcode == "" ? "postcode" : @postalcode}/#{@homenuber == "" ? "huisnummer" : @homenumber}/all.ics"
  @generated_url += "?time=#{CGI.escape(@time)}" if !@allday
  if @alarm != "disabled"
    @generated_url += (!@allday ? "&" : "?")
    @generated_url += "alarm=#{@alarm}"
  end
  
  erb :index
end

get '/:postalcode/:housenumber/all.:format' do

  #sanitize parameters
  raise "no postal code provided" if params[:postalcode].nil? 
  @postalcode = extract_postalcode(params[:postalcode])
  
  raise "no house number provided" if params[:housenumber].nil?
  @housenumber = params[:housenumber].to_i
  
  time = Time.parse(params[:time]) if params[:time] && params[:time] != ""
  alarm = params[:alarm].to_i if params[:alarm]
  
  
  
  #fetch events
  @all_events = Sinatra::Cache.cache("#{@postalcode}/#{@housenumber}/#{time}", :expire => 60*60*24) do
    TwenteMilieuData.new(@postalcode, @housenumber, time).all_events
  end
  
  case params[:format]
  when "ics"
    content_type 'text/calendar'
    icalendar = @all_events.to_icalendar
    
    icalendar.prodid = "afcal"
    icalendar.custom_property("X-WR-CALNAME;VALUE=TEXT", "Twente Milieu Afvaldata")
    icalendar.custom_property("X-WR-CALDESC;VALUE=TEXT", 
    "De data waarop Twente Milieu het restafval, GFT, papier etc. ophaalt bij #{@postalcode} #{@housenumber}")
    
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
