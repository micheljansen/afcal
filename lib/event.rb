require 'rubygems'
# require 'icalendar'
require 'vendor/icalendar-1.1.0/lib/icalendar'
require 'date'

class Event
  include Comparable
  
  attr :date
  attr :description
  
  def initialize(date, description)
    @date = date
    @description = description
  end
  
  def to_s
    "#{date.to_s}: #{description}"
  end
  
  def <=>(other)
    date <=> other.date
  end
  
  def to_icalendar_event
    event = Icalendar::Event.new
    
    event.start       = date
    event.end         = date
    event.summary     = description
    
    return event
  end
end