# frozen_string_literal: true

class ShortFormatData
  def initialize(all_file_paths, is_file)
    @all_file_paths = all_file_paths
    @is_file = is_file
  end

  # 画面にファイル一覧と各ファイルの詳細情報を出力用の形式にする（lオプションがない場合）
  def obtain_metadata
    # コマンドライン引数にファイルが与えられている場合は、ファイル名=ファイルパスにする必要がある
    if @is_file
      @all_file_paths
    else
      @all_file_paths.map { |file_path| File.basename(file_path) }
    end
  end
end
