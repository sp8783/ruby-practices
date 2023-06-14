# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')
score_strike = 10
shots = []

scores.each do |s|
  if s == 'X'
    shots << score_strike
    shots << 0
  else
    shots << s.to_i
  end
end

frames = shots.each_slice(2).to_a
point = 0
frames.length.times do |frame_index|
  current_frame = frames[frame_index]
  next_frame = frames[frame_index + 1]
  next_next_frame = frames[frame_index + 2]

  point += current_frame.sum
  next if frame_index >= 9 # last frame

  if current_frame[0] == score_strike # strike
    point += if next_frame[0] == score_strike
               next_frame[0] + next_next_frame[0]
             else
               next_frame.sum
             end
  elsif current_frame.sum == 10 # spare
    point += next_frame[0]
  end
end
puts point
