clc 
clearvars
close all

[y, Fs] = audioread('prova_vocoder_16.wav');
duration_file = 5;
duration_wind = 0.02;
D = duration_file/duration_wind; % ratio between file and 20ms window
N = length(y);
L = N / D ; % number of window samples   
window = hamming(L);


i = 0; j = 0;
correlations = zeros(2*D, 2*L-1);
excerpt = zeros(L,1);
while (i+L <= N)
    excerpt(1:L) = (y(i+1:i+L).* window);
    r = xcorr(excerpt);
    %[peaks, locs] = findpeaks(r);
    i = i+ L/2; 
    
    j = j+1;
    
    correlations(j,:) = r;
end


% Estimate LPC coefficients using Levinson's method
lpc_order = 18; % order of LPC filter, we'll have lpc_order + 1 coefficients
coefs = zeros(2*D, lpc_order + 1);
for i = 1:2*D
    autocorrVec = correlations(i,1:lpc_order+1);
    err(1) = autocorrVec(1);
    k(1) = 0;
    A = [];
    for index=1:lpc_order
        numerator = [1 A.']*autocorrVec(index+1:-1:2)';
        denominator = -1*err(index);
        k(index) = numerator/denominator;
        A = [A+k(index)*flipud(A); k(index)];
        err(index+1) = (1-k(index)^2)*err(index);
    end
    coefs(i,:) = [1; A]';
end

msg=midi();%receiving a MIDI message (5 seconds)

gain=5;

freqs=zeros(1,D);
time=0;
m=2;
for i=1:2*D
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
    else
        %note off
        freqs(i)=30000;
    end
end

excitation_signal=zeros(1,N);
output=zeros(1,N);
win=1;
for i=1:L/2:N-L
    excitation_signal(i:i+L-1)=treno(L,freqs(win));
    output(i:i+L-1)=filter(gain,coefs(win,:),excitation_signal(i:i+L-1));
    win=win+1;
end

audiowrite('output.wav',cast(output,'uint8'),Fs);