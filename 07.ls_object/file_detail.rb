# frozen_string_literal: true

require 'etc'

class FileDetail
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

  def initialize(file_path, is_file)
    @file_path = file_path
    @filename = is_file ? file_path : File.basename(file_path)
    @stat = File.lstat(file_path)
  end

  def permission = convert_stat_mode_to_permission_code_for_ls_command(@stat)
  def hardlink = @stat.nlink.to_s
  def user_name = Etc.getpwuid(@stat.uid).name
  def group_name = Etc.getgrgid(@stat.gid).name
  def file_size = @stat.size.to_s
  def timestamp = @stat.mtime.strftime('%b %e %R')
  def file_name = FTYPE[@stat.ftype] == 'l' ? "#{@filename} -> #{File.readlink(@file_path)}" : @filename
  def block = @stat.blocks

  private

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
