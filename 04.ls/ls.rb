# frozen_string_literal: true

NUMBER_OF_COLUMNS = 3
WIDTH_BETWEEN_COLUMNS = 2

def main
  all_files = glob_and_sort_files
  print_all_files(all_files)
end

# lsコマンド同様の並び順で、ファイルの配列を取得する
def glob_and_sort_files
  all_files = Dir.glob('*')
  all_files.sort! { |x, y| x.casecmp(y).nonzero? || y <=> x }
end

# 画面にファイル一覧を出力する
def print_all_files(all_files)
  num_rows = (all_files.size.to_f / NUMBER_OF_COLUMNS).ceil
  widths_per_column = calculation_width_columns(all_files, num_rows)

  (0...num_rows).each do |row|
    subset_files = all_files.select.each_with_index { |_, i| i % num_rows == row }
    puts subset_files.each_with_index.map { |file, i| file.ljust(widths_per_column[i]) }.join
  end
end

# 出力時の幅を列毎に計算する
def calculation_width_columns(all_files, num_rows)
  all_files.each_slice(num_rows).map do |files|
    files.map(&:size).max + WIDTH_BETWEEN_COLUMNS
  end
end

main
