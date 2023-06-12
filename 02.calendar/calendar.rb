require 'optparse'
require 'date'

# コマンドラインのオプションから年月を受け取る
def get_option_year_and_month()
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
  first_date = Date.new(year, month, 1)
  last_date = Date.new(year, month, -1)

  puts first_date.strftime("%B %Y").center(20)
  puts "Su Mo Tu We Th Fr Sa"

  print_line = " " * 3 * first_date.wday

  (first_date..last_date).each do |date|
    print_line += date.day.to_s.rjust(2) + " "
    if date.saturday? or date == last_date
      puts print_line
      print_line = ""
    end
  end
end

year, month = get_option_year_and_month
print_calendar(year, month)
