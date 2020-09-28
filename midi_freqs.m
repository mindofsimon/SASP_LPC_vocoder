function [freqs, pitch] = midi_freqs(msg, n_frames, duration_frames, samples_frame)
time=0;
freqs = zeros(1, n_frames);
pitch = zeros(1, n_frames);
m=2;
for i=1:n_frames
    if(m<=length(msg))
        if (msg(m).Timestamp-time-msg(m-1).Timestamp<0.01)
            m=m+1;
            time=0;
        else
            time=time+0.01;
        end
    else
        m=length(msg);
    end
    if(msg(m-1).Velocity>0)
        freqs(i)=440 * 2^((msg(m-1).Note-69)/12);
        pitch(i) = freqs(i)/(duration_frames*samples_frame);
    else
        %note off
        freqs(i)=30000;
        pitch(i) = freqs(i)/(duration_frames*samples_frame);
    end
    
end

end

