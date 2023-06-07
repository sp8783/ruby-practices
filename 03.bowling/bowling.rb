# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = []
shots.each_slice(2) do |s|
  frames << s
end

point = 0
frames.length.times do |frame_index|
  point += frames[frame_index].sum
  next if frame_index >= 9 # last frame

  if frames[frame_index][0] == 10 # strike
    point += if frames[frame_index + 1][0] == 10
               frames[frame_index + 1][0] + frames[frame_index + 2][0]
             else
               frames[frame_index + 1].sum
             end
  elsif frames[frame_index].sum == 10 # spare
    point += frames[frame_index + 1][0]
  end
end
puts point
