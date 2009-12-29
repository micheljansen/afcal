require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'cgi'
# require 'icalendar'
require 'vendor/icalendar-1.1.0/icalendar'
require 'date'

require 'lib/event'
require 'lib/date_translations'
require 'lib/to_icalendar_proxy'

class TwenteMilieuData
  include DateTranslations
  
  EVENT_TYPES = {
    "Restafval" => 7,
    "GFT-afval" => 6,
    "Papier en karton" => 5,
    "Plastic verpakkingsmateriaal" => 8
  }
  
  def initialize(postalcode, housenumber, time = nil)
    @postalcode = postalcode
    @housenumber = housenumber
    @time = time
  end
  
  def fetch_data
    url = "http://twentemilieu.nl/site/pagina.php?formActie=afvalkalender&formulier=afvalkalender&id=5&postcode=#{CGI.escape(@postalcode)}&huisnummer=#{CGI.escape(@housenumber)}&fracties%5B%5D=7&fracties%5B%5D=6&fracties%5B%5D=5&fracties%5B%5D=8"
    puts "Fetching data from '#{url}'"
    @doc = Nokogiri::HTML(open(url))
  end
  
  def refresh
    fetch_data
  end
  
  def dates_for(id)
    date_elements = doc.css("span[id^=datum_#{id}_]")
    dates = date_elements.map{|d| parse_dutch_date(d.content.to_s)}

    unless @time.nil?
      dates = dates.map do |date| 
        DateTime.new(date.year, date.month, date.day, @time.hour, @time.min)
      end
    end
    
    return dates
  end
  
  # array of Events
  def all_events
    events = []
    events.extend(ToIcalendarProxy)
    
    event_types.each do |event_type|
      dates_for(event_id_for(event_type)).each do |event_date|
        events << Event.new(event_date, event_type)
      end
    end
    
    return events
  end
  
  # icalendar format
  
  def event_types
    EVENT_TYPES.keys
  end
  
  def event_id_for(event_type)
    EVENT_TYPES[event_type]
  end
  
  private
  
  def doc
    @doc ||= fetch_data
  end
end