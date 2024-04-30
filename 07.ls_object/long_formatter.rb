# frozen_string_literal: true

require 'etc'
require_relative 'file_detail'

class LongFormatter
  def initialize(all_file_paths, is_file)
    @all_file_details = all_file_paths.map { |file_path| FileDetail.new(file_path, is_file) }
    @is_file = is_file
  end

  def format
    max_lengths = calculation_max_length_for_variable_length_columns
    total_blocks = calculation_total_blocks

    print_format = @is_file ? [] : [['total', total_blocks.to_s].join(' ')]
    print_cols = %i[permission hardlink user_name group_name file_size timestamp file_name]
    @all_file_details.each do |detail|
      print_format << print_cols.map { |col| detail.send(col).rjust(max_lengths[col]) }.join(' ')
    end
    print_format
  end

  private

  def calculation_max_length_for_variable_length_columns
    variable_length_columns = %i[hardlink user_name group_name file_size]
    max_lengths = Hash.new(0)
    @all_file_details.each do |detail|
      variable_length_columns.each { |col| max_lengths[col] = [max_lengths[col], detail.send(col).size].max }
    end
    max_lengths
  end

  def calculation_total_blocks
    @all_file_details.map(&:block).sum / 2 # Linuxのブロック数 = File::Statのブロック数 / 2
  end

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
