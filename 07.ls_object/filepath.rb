# frozen_string_literal: true

class Filepath
  def initialize(path, options)
    @path = path
    @options = options
  end

  def make_all_file_paths
    sort_file_paths(glob_file_paths)
  end

  private

  def glob_file_paths
    if @path.nil?
      @options['a'] ? Dir.entries('.') : Dir.glob('*')
    elsif FileTest.directory?(@path)
      @options['a'] ? Dir.entries(@path).map{ |path| @path + "/" + path } : Dir.glob(File.join(@path, '*'))
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
