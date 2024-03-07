# frozen_string_literal: true

require_relative 'filepath'
require_relative 'short_formatter'
require_relative 'long_formatter'

class LsCommand
  def initialize(path, options)
    @path = path
    @options = options
  end

  def execute
    all_file_paths = Filepath.new(@path, @options).make_all_file_paths
    is_file = @path.nil? ? false : FileTest.file?(@path)

    if @options['l']
      LongFormatter.new(all_file_paths, is_file).display_all_files_in_long_format
    else
      ShortFormatter.new(all_file_paths, is_file).display_all_files_in_short_format
    end
  end
end
