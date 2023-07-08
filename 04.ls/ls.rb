# frozen_string_literal: true

require 'optparse'

NUMBER_OF_COLUMNS = 3
WIDTH_BETWEEN_COLUMNS = 2

def main
  options = ARGV.getopts('a', 'r')
  all_files = glob_and_sort_files(options['a'], options['r'])
  print_all_files(all_files)
end

# lsコマンド同様の並び順で、ファイルの配列を取得する
def glob_and_sort_files(is_all, is_reverse)
  all_files = is_all ? Dir.entries('.') : Dir.glob('*')
  all_files.sort! { |x, y| x.casecmp(y).nonzero? || y <=> x }
  is_reverse ? all_files.reverse : all_files
end

# 画面にファイル一覧を出力する
def print_all_files(all_files)
  num_rows = (all_files.size.to_f / NUMBER_OF_COLUMNS).ceil
  widths_per_column = calculation_width_columns(all_files, num_rows)

  (0...num_rows).each do |row|
    subset_files = all_files.select.each_with_index { |_, i| i % num_rows == row }
    puts subset_files.each_with_index.map { |file, i| ljust_for_multibyte_characters(file, widths_per_column[i]) }.join
  end
end

# 出力時の幅を列毎に計算する
def calculation_width_columns(all_files, num_rows)
  all_files.each_slice(num_rows).map do |files|
    files.map { |file| size_for_multibyte_characters(file) }.max + WIDTH_BETWEEN_COLUMNS
  end
end

# マルチバイト文字を考慮して左詰めした文字列を返す
def ljust_for_multibyte_characters(string, width, padding = ' ')
  multibyte_width = size_for_multibyte_characters(string)
  padding_size = [0, width - multibyte_width].max
  string + padding * padding_size
end

# 「マルチバイト文字1文字 = 半角文字2文字」として文字列の長さをカウントする
def size_for_multibyte_characters(string)
  string.each_char.map { |c| c.bytesize == 1 ? 1 : 2 }.sum
end

main
