# frozen_string_literal: true

require_relative 'short_format_data'
require_relative 'long_format_data'

NUMBER_OF_COLUMNS = 3
WIDTH_BETWEEN_COLUMNS = 2

class LsCommand
  def initialize(path, options)
    @path = path || '.'
    @options = options
  end

  def execute
    all_file_paths = make_all_file_paths
    is_file = @path && FileTest.file?(@path)

    obtainer = @options['l'] ? LongFormatData : ShortFormatData
    all_metadata = obtainer.new(all_file_paths, is_file).obtain_metadata

    if @options['l']
      display_files_for_long_format(all_metadata)
    else
      display_files_for_short_format(all_metadata)
    end
  end

  private

  def make_all_file_paths
    sort_file_paths(glob_file_paths)
  end

  def glob_file_paths
    if FileTest.directory?(@path)
      @options['a'] ? Dir.entries(@path).map { |path| "#{@path}/#{path}" } : Dir.glob(File.join(@path, '*'))
    elsif FileTest.file?(@path)
      [@path]
    else
      puts "ls: cannot access '#{@path}': No such file or directory"
      exit
    end
  end

  def sort_file_paths(all_file_paths)
    all_file_paths.sort! { |x, y| x.casecmp(y).nonzero? || y <=> x }
    @options['r'] ? all_file_paths.reverse : all_file_paths
  end

  def display_files_for_long_format(all_file_details)
    if all_file_details[0].key?(:total_blocks)
      total_blocks = all_file_details.shift[:total_blocks]
      puts "total #{total_blocks}"
    end
    max_lengths = calc_max_length_for_variable_length_columns(all_file_details)
    all_file_details.each do |detail|
      detail.delete(:block)
      puts detail.map { |k, v| v.rjust(max_lengths[k]) }.join(' ')
    end
  end

  def calc_max_length_for_variable_length_columns(all_file_details)
    variable_length_columns = %i[hardlink user_name group_name file_size]
    max_lengths = Hash.new(0)
    all_file_details.each do |detail|
      variable_length_columns.each { |col| max_lengths[col] = [max_lengths[col], detail[col].size].max }
    end
    max_lengths
  end

  def display_files_for_short_format(all_files)
    num_rows = (all_files.size.to_f / NUMBER_OF_COLUMNS).ceil
    widths_per_column = calculation_width_columns(all_files, num_rows)
    (0...num_rows).each do |row|
      puts all_files.select.each_with_index { |_, i| i % num_rows == row }
                    .map.with_index { |file, i| ljust_for_multibyte_characters(file, widths_per_column[i]) }
                    .join
    end
  end

  def calculation_width_columns(all_files, num_rows)
    all_files.each_slice(num_rows).map do |files|
      files.map { |file| size_for_multibyte_characters(file) }.max + WIDTH_BETWEEN_COLUMNS
    end
  end

  def ljust_for_multibyte_characters(string, width, padding = ' ')
    multibyte_width = size_for_multibyte_characters(string)
    padding_size = [0, width - multibyte_width].max
    string + padding * padding_size
  end

  def size_for_multibyte_characters(string)
    string.each_char.map { |c| c.bytesize == 1 ? 1 : 2 }.sum
  end
end
