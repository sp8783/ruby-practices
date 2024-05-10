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
    @all_file_details.each do |detail|
      print_format << [
        detail.permission,
        detail.hardlink.rjust(max_lengths[:hardlink]),
        detail.user_name.rjust(max_lengths[:user_name]),
        detail.group_name.rjust(max_lengths[:group_name]),
        detail.file_size.rjust(max_lengths[:file_size]),
        detail.timestamp,
        detail.file_name
      ].join(' ')
    end
    print_format
  end

  private

  def calculation_max_length_for_variable_length_columns
    max_lengths = Hash.new(0)
    @all_file_details.each do |detail|
      max_lengths[:hardlink] = [max_lengths[:hardlink], detail.hardlink.size].max
      max_lengths[:user_name] = [max_lengths[:user_name], detail.user_name.size].max
      max_lengths[:group_name] = [max_lengths[:group_name], detail.group_name.size].max
      max_lengths[:file_size] = [max_lengths[:file_size], detail.file_size.size].max
    end
    max_lengths
  end

  def calculation_total_blocks
    @all_file_details.map(&:block).sum / 2 # Linuxのブロック数 = File::Statのブロック数 / 2
  end
end
