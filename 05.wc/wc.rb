# frozen_string_literal: true

require 'optparse'
require 'etc'

def main
  options = ARGV.getopts('l', 'w', 'c')
  display_flags = build_display_flags(options)

  if ARGV.empty?
    wc_with_no_argument(display_flags)
  else
    wc_with_filepaths(ARGV, display_flags)
  end
end

def build_display_flags(options)
  display_flags = options.values.any? ? options : options.transform_values { true }
  display_flags.transform_keys('l' => :line, 'w' => :word, 'c' => :byte)
end

def wc_with_no_argument(display_flags)
  text = $stdin.read
  file_details = [make_file_detail(text, '', 'stdin')]
  display_file_details(file_details, display_flags)
end

def wc_with_filepaths(filepaths, display_flags)
  file_details = filepaths.map do |filepath|
    if File.file?(filepath)
      text = File.read(filepath)
      make_file_detail(text, filepath, 'file')
    elsif File.directory?(filepath)
      make_file_detail('', filepath, 'directory')
    else
      make_file_detail('', filepath, 'no_exist')
    end
  end
  file_details << make_total_value_to_file_detail(file_details) if file_details.size >= 2
  display_file_details(file_details, display_flags)
end

def make_file_detail(text, filepath, category)
  {
    line: count_lines(text),
    word: count_words(text),
    byte: count_bytes(text),
    name: filepath,
    category:
  }
end

def count_lines(text)
  text.lines.count
end

def count_words(text)
  text.split(/\s+/).size
end

def count_bytes(text)
  text.bytesize
end

def make_total_value_to_file_detail(file_details)
  {
    line: file_details.sum { |hash| hash[:line] },
    word: file_details.sum { |hash| hash[:word] },
    byte: file_details.sum { |hash| hash[:byte] },
    name: 'total'
  }
end

def display_file_details(file_details, display_flags)
  column_width = calc_column_width(file_details, display_flags)
  file_details.each do |hash|
    if hash[:category] == 'no_exist'
      puts "wc: #{hash[:name]}: No such file or directory"
      next
    elsif hash[:category] == 'directory'
      puts "wc: #{hash[:name]}: Is a directory"
    end

    print "#{hash[:line].to_s.rjust(column_width)} " if display_flags[:line]
    print "#{hash[:word].to_s.rjust(column_width)} " if display_flags[:word]
    print "#{hash[:byte].to_s.rjust(column_width)} " if display_flags[:byte]
    puts hash[:name]
  end
end

def calc_column_width(file_details, display_flags)
  if display_flags.values.count(true) == 1 && file_details.size == 1
    return 0 # 「（ファイル名を除く）表示列が1列」かつ「入力が1ファイルのみ」の場合、本物のwcコマンドでは空白埋めをしない
  end

  target_file_details = file_details[-1] # 入力が1ファイルの場合はそのファイルの行を、複数ファイルの場合はtotal行を元に列幅を計算する（total行が一番文字数が多いため）
  maximum_value_length = target_file_details.values_at(*%i[line word byte]).map { |value| value.to_s.size }.max
  if target_file_details[:category] == 'stdin' || file_details.map { |h| h[:category] }.include?('directory')
    [maximum_value_length, 7].max # 「標準入力」または「入力にディレクトリを含む」の場合、本物のwcコマンドでは列幅が半角7文字分になる
  else
    maximum_value_length
  end
end

main
