# frozen_string_literal: true

require_relative 'frame'
require_relative 'shot'

class Game
  def initialize(shots)
    @shots = shots
  end

  def calc_score
    total_score = 0
    @frames = build_frames
    @frames.each_with_index do |frame, idx|
      total_score += frame.calc_score
      total_score += calc_additional_score_in_one_frame(idx) if idx < 9 # not last frame
    end
    total_score
  end

  def build_frames
    shots = @shots.map do |shot|
      if shot == 'X'
        [shot, 0]
      else
        shot.to_i
      end
    end.flatten
    shots.each_slice(2).map { |f| Frame.new(f) }
  end

  def calc_additional_score_in_one_frame(idx)
    if @frames[idx].strike?
      if @frames[idx + 1].strike?
        Frame::ALL_PINS + @frames[idx + 2].shots[0].calc_score
      else
        @frames[idx + 1].calc_score
      end
    elsif @frames[idx].spare?
      @frames[idx + 1].shots[0].calc_score
    else
      0
    end
  end
end
