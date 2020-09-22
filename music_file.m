function music_freqs = music_file(file_name, win_length ,n_frames)
    [y,fs]=audioread(file_name);
    S = zeros(n_frames, fs/2);
    k = zeros(n_frames, 1);
    for m = 0:n_frames-1
    
        % signal windowing 
        y_m = y(m*win_length +1 : m*win_length + win_length/2).*hamming(win_length)';

        % compute the FFT
        Y = fft(y_m,fs);

        % retain only the positive frequencies up to the Nyquist index
        Y = Y(1:fs/2);

        % populate S with the magnitude of the m-th spectrum
        S(m+1,:) = abs(Y);        
    
    end

    % magnitude to dB
    S_dB = 20*log10(S);

    % find the indices of the spectral maxima
    k_b = zeros(n_frames,1);
    for m = 0 : n_frames-1
        [~,k_b(m+1)] = max(S_dB(m+1 , : ));
    end
    k_k = 1;
    d = 2*k_k+1;
    k(:,1)= medfilt1(k_b,d);
    
    music_freqs=k;
end

