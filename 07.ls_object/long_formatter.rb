# frozen_string_literal: true

require 'etc'

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

class LongFormatter
  def initialize(all_file_paths, is_file)
    @all_file_paths = all_file_paths
    @is_file = is_file
  end

  # 画面にファイル一覧と各ファイルの詳細情報を出力用の形式にする（lオプションがある場合）
  def format
    all_file_details = make_all_file_details
    max_lengths = calc_max_length_for_variable_length_columns(all_file_details)
    total_blocks = calc_total_blocks(all_file_details)

    print_format = @is_file ? [] : [['total', total_blocks.to_s].join(' ')]
    all_file_details.each do |detail|
      detail.delete(:block)
      print_format << detail.map { |k, v| v.rjust(max_lengths[k]) }.join(' ')
    end
    print_format
  end

  private

  # lオプションで表示させる全ファイルの詳細情報を返す
  def make_all_file_details
    @all_file_paths.map do |file_path|
      stat = File.lstat(file_path)

      # コマンドライン引数にファイルが与えられている場合は、ファイル名=ファイルパスにする必要がある
      filename = @is_file ? file_path : File.basename(file_path)
      {
        permission: convert_stat_mode_to_permission_code_for_ls_command(stat),
        hardlink: stat.nlink.to_s,
        user_name: Etc.getpwuid(stat.uid).name,
        group_name: Etc.getgrgid(stat.gid).name,
        file_size: stat.size.to_s,
        timestamp: stat.mtime.strftime('%b %e %R'),
        file_name: FTYPE[stat.ftype] == 'l' ? "#{filename} -> #{File.readlink(filename)}" : filename,
        block: stat.blocks
      }
    end
  end

  # 可変長の文字列が入る列に対し、各列の最大文字数を計算する
  def calc_max_length_for_variable_length_columns(all_file_details)
    variable_length_columns = %i[hardlink user_name group_name file_size]
    max_lengths = Hash.new(0)
    all_file_details.each do |detail|
      variable_length_columns.each { |col| max_lengths[col] = [max_lengths[col], detail[col].size].max }
    end
    max_lengths
  end

  # 全ファイルに割り当てられている合計のブロック数を計算する
  def calc_total_blocks(all_file_details)
    all_file_details.map { |detail| detail[:block] }.sum / 2 # Linuxのブロック数 = File::Statのブロック数 / 2
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
end
