# frozen_string_literal: true

require 'optparse'
require 'etc'

NUMBER_OF_COLUMNS = 3
WIDTH_BETWEEN_COLUMNS = 2
FTYPE = {
  'fifo' => 'p',
  'characterSpecial' => 'c',
  'directory' => 'd',
  'blockSpecial' => 'b',
  'file' => '-',
  'link' => 'l',
  'socket' => 's'
}.freeze
PERMISSION = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

def main
  options = ARGV.getopts('a', 'r', 'l')
  all_files = glob_and_sort_files(options['a'], options['r'])
  if options['l']
    print_all_files_with_details(all_files)
  else
    print_all_files(all_files)
  end
end

# lsコマンド同様の並び順で、ファイルの配列を取得する
def glob_and_sort_files(is_all, is_reverse)
  all_files = is_all ? Dir.entries('.') : Dir.glob('*')
  all_files.sort! { |x, y| x.casecmp(y).nonzero? || y <=> x }
  is_reverse ? all_files.reverse : all_files
end

# 画面にファイル一覧を出力する（lオプションがない場合）
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

# 画面にファイル一覧と各ファイルの詳細情報を出力する（lオプションがある場合）
def print_all_files_with_details(all_files)
  all_file_details = make_all_file_details(all_files)
  max_lengths = calc_max_length_for_variable_length_columns(all_file_details)
  total_blocks = calc_total_blocks(all_file_details)

  puts "total #{total_blocks}"
  all_file_details.each do |detail|
    detail.delete('block')
    puts detail.each.map { |k, v| v.rjust(max_lengths[k]) }.join(' ')
  end
end

# lオプションで表示させる全ファイルの詳細情報を返す
def make_all_file_details(all_files)
  all_file_details = []
  all_files.each do |file|
    stat = File.lstat(file)
    file_details = {
      'permission' => convert_stat_mode_to_permission_code_for_ls_command(stat),
      'hardlink' => stat.nlink.to_s,
      'user_name' => Etc.getpwuid(stat.uid).name,
      'group_name' => Etc.getgrgid(stat.gid).name,
      'file_size' => stat.size.to_s,
      'timestamp' => stat.mtime.strftime('%b %e %R'),
      'file_name' => FTYPE[stat.ftype] == 'l' ? "#{file} -> #{File.readlink(file)}" : file,
      'block' => stat.blocks
    }
    all_file_details << file_details
  end
  all_file_details
end

# 可変長の文字列が入る列に対し、各列の最大文字数を計算する
def calc_max_length_for_variable_length_columns(all_file_details)
  variable_length_columns = %w[hardlink user_name group_name file_size]
  max_lengths = Hash.new(0)
  all_file_details.each do |detail|
    variable_length_columns.each { |col| max_lengths[col] = [max_lengths[col], detail[col].size].max }
  end
  max_lengths
end

# 全ファイルに割り当てられている合計のブロック数を計算する
def calc_total_blocks(all_file_details)
  all_file_details.each.map { |detail| detail['block'] }.sum / 2 # Linuxのブロック数 = File::Statのブロック数 / 2
end

# File::stat#modeで得たパーミッションコードから、lsコマンド用のパーミッションコードに変換する
def convert_stat_mode_to_permission_code_for_ls_command(stat)
  permission = stat.mode.to_s(8)[-3..].chars.map { |i| PERMISSION[i] }.join
  if stat.setuid?
    permission[2] = (permission[2] == 'x' ? 's' : 'S')
  end
  if stat.setgid?
    permission[5] = (permission[5] == 'x' ? 's' : 'S')
  end
  if stat.sticky?
    permission[8] = (permission[8] == 'x' ? 't' : 'T')
  end
  FTYPE[stat.ftype] + permission
end

main
