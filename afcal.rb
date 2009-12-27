require 'rubygems'
require 'sinatra'
require 'time'

require 'lib/twente_milieu_data'

get '/' do
  "<ul>
    #{all_events.map{|e| "<li>#{e.to_s}</li>"}.join("\n")}
  </ul>"
end

get '/:postalcode/:housenumber/all.:format' do
  #sanitize parameters
  time = nil
  
  if params[:time] && params[:time] != ""
    time = Time.parse(params[:time])
    # DateTime.new(date.year, date.month, date.day, 18, 00)
  end
  
  #fetch events
  all_events = TwenteMilieuData.new(params[:postalcode], params[:housenumber], time).all_events
  
  case params[:format]
  when "ics"
    content_type 'text/calendar'
    all_events.to_icalendar.to_ical
  else
    "<ul>
      #{all_events.map{|e| "<li>#{e.to_s}</li>"}.join("\n")}
    </ul>"
  end
end