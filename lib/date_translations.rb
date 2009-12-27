module DateTranslations
  MONTH_TO_NUMBER = {
      :januari => 1,
      :februari => 2,
      :maart => 3,
      :april => 4, 
      :mei => 5, 
      :juni => 6, 
      :juli => 7, 
      :augustus => 8,
      :september => 9,
      :oktober => 10,   
      :november => 11, 
      :december => 12
    }
    
  def parse_dutch_date(dutch_date)
    data = dutch_date.match(/.* ([0-9]+) (.*) ([0-9]+)/).captures
    raise ArgumentError, "could not parse '#{dutch_data}': invalid length '#{data.length}'" if data.length != 3
    Date.new(data[2].to_i, month_to_number(data[1]), data[0].to_i)
  end

  def month_to_number(dutch_month)
    number = MONTH_TO_NUMBER[dutch_month.to_s.downcase.to_sym]
    raise ArgumentError, "invalid month #{dutch_month}" if number.nil?
    return number
  end
  
end