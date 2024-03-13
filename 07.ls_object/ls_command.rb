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

    formatter = @options['l'] ? LongFormatter : ShortFormatter
    formatter.new(all_file_paths, is_file).format.each do |line|
      puts line
    end
  end
end
