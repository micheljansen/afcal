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
  raise "no postal code provided" if params[:postalcode].nil? 
  postalcode = params[:postalcode].gsub(/[^a-z|^0-9]/i, "")[0..5]
  
  raise "no house number provided" if params[:housenumber].nil?
  housenumber = params[:housenumber].to_i
  
  time = Time.parse(params[:time]) if params[:time] && params[:time] != ""
  
  #fetch events
  all_events = TwenteMilieuData.new(params[:postalcode], params[:housenumber], time).all_events
  
  case params[:format]
  when "ics"
    content_type 'text/calendar'
    all_events.to_icalendar.to_ical
  else
    "
    postcode: #{postalcode}<br/>
    huisnummer: #{housenumber}<br />
    <ul>
      #{all_events.map{|e| "<li>#{e.to_s}</li>"}.join("\n")}
    </ul>"
  end
end