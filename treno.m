function sig =treno(frame_length, pitch) 
sig = zeros(1, frame_length);
frame_ratio = frame_length/pitch;
for f = 1: frame_length
    if (f /frame_ratio == floor(f /frame_ratio))
        sig(f) = 1;
    else
        sig(f) = 0;
    end
end
end

