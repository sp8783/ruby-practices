# frozen_string_literal: true

require_relative 'short_formatter'
require_relative 'long_formatter'

class LsCommand
  def initialize(path, options)
    @path = path || '.'
    @options = options
  end

  def execute
    all_file_paths = make_all_file_paths
    is_file = @path && FileTest.file?(@path)

    formatter = @options['l'] ? LongFormatter : ShortFormatter
    formatter.new(all_file_paths, is_file).format.each do |line|
      puts line
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
end
