require 'rubygems'
# require 'icalendar'
require 'vendor/icalendar-1.1.0/icalendar'
require 'date'

module ToIcalendarProxy
  include Icalendar
  
  def to_icalendar
    cal = Calendar.new
    
    self.map do |element|
      cal.add_event(element.to_icalendar_event)
    end
    
    return cal
  end
end