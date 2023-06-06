# コマンドラインのオプションから年月を受け取る
def get_option_year_and_month()
  require 'optparse'
  require 'date'

  options = {year: Date.today.year, month: Date.today.month}

  OptionParser.new do |opts|
    opts.on('-y YEAR') { |v| options[:year] = v.to_i }
    opts.on('-m MONTH') { |v| options[:month] = v.to_i }
    opts.parse!
  end

  return options[:year], options[:month]
end

# 指定した年月のカレンダーを表示する
def print_calendar(year, month)
  require 'date'

  first_date = Date.new(year, month, 1)
  last_day = Date.new(year, month, -1).day

  puts first_date.strftime("%B %Y").center(20)
  puts "Su Mo Tu We Th Fr Sa"

  print_line = " " * 3 * first_date.wday
  
  (1..last_day).each do |day|
    print_line += day.to_s.rjust(2) + " "
    if print_line.length == 3 * 7 or day == last_day
      puts print_line
      print_line = ""
    end
  end
end

year, month = get_option_year_and_month
print_calendar(year, month)