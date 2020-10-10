function [ltpDelay, i] = music_file(file_name, samples_frame, duration_frames ,i)
    [y,fs]=audioread(file_name);
    
        % signal windowing 
        y_i = y(i+1 : i+samples_frame);

        % compute the FFT
        Y = fft(y_i,fs);

        % retain only the positive frequencies up to the Nyquist index
        Y = Y(1:fs/2);

        % populate S with the magnitude of the m-th spectrum
        S = abs(Y);        
    

    % magnitude to dB
    S_dB = 20*log10(S);

    % find the indices of the spectral maxima
    [~,k_b] = max(S_dB);
    
    ltpDelay = samples_frame/((k_b)*duration_frames);
    i=i+samples_frame;
end

