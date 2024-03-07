# frozen_string_literal: true

NUMBER_OF_COLUMNS = 3
WIDTH_BETWEEN_COLUMNS = 2

class ShortFormatter
  def initialize(all_file_paths, is_file)
    @all_file_paths = all_file_paths
    @is_file = is_file
  end

  def display_all_files_in_short_format
    # コマンドライン引数にファイルが与えられている場合は、ファイル名=ファイルパスにする必要がある
    all_files =
      if @is_file
        @all_file_paths
      else
        @all_file_paths.map { |file_path| File.basename(file_path) }
      end

    num_rows = (all_files.size.to_f / NUMBER_OF_COLUMNS).ceil
    widths_per_column = calculation_width_columns(all_files, num_rows)

    (0...num_rows).each do |row|
      subset_files = all_files.select.each_with_index { |_, i| i % num_rows == row }
      puts subset_files.each_with_index.map { |file, i| ljust_for_multibyte_characters(file, widths_per_column[i]) }.join
    end
  end

  private

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
end
