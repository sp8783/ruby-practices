# frozen_string_literal: true

require_relative 'shot'

class Frame
  ALL_PINS = 10

  attr_reader :shots

  def initialize(shots)
    @shots = shots.map { |s| Shot.new(s) }
  end

  def calc_score
    @shots.map(&:calc_score).sum
  end

  def strike?
    @shots[0].calc_score == ALL_PINS
  end

  def spare?
    calc_score == ALL_PINS
  end
end
