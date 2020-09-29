function [freqs, pitch ,i, t, state] = midi_freqs(msg, duration_frames, samples_frame,i,t)
time=msg(i-1).Timestamp+t;

    if(i==length(msg))
        %i=i; 
    elseif (time-msg(i).Timestamp<0.02)
        i=i+1;
        t=0;
    else
        t=t+0.01;
    end
    
    
    if(msg(i).Velocity>0)
        state=2;
        freqs=440 * 2^((msg(i).Note-69)/12);
        pitch = samples_frame/(freqs*duration_frames);
    else
        %note off
        state=1;
        freqs=10;
        pitch = samples_frame/(freqs*duration_frames);
    end
end

