# frozen_string_literal: true

class Shot
  def initialize(mark)
    @mark = mark
  end

  def calc_score
    @mark == 'X' ? 10 : @mark.to_i
  end
end
