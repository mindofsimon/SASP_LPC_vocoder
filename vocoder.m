clc 
clearvars
close all

[y, Fs] = audioread('prova_vocoder_16.wav');


duration_file = 5;
duration_wind = 0.02;
D = duration_file/duration_wind; % ratio between file and 20ms window
N = length(y);
L = N / D ; % number of window samples   
window = rectwin(L);


i = 0; j = 0;
correlations = zeros(D, 2*L-1);
excerpt = zeros(L,1);
for i=1:L:N-L
    excerpt = (y(i:i+L-1).*window);
    [r , lg]= xcorr(excerpt);
    %r(lg<0) = [];
    
    %[peaks, locs] = findpeaks(r);
    
    j = j+1;
    
    correlations(j,:) = r;
end



% %Estimate LPC coefficients using Levinson's method
lpc_order = 18; % order of LPC filter, we'll have lpc_order + 1 coefficients
coefs = zeros(D, lpc_order+1 );
coefs(:,1)=1;
for i = 1:D
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
    %coefs(i,2:end) = levinson(correlations(i, 1:lpc_order+1));
    coefs(i,2:end) = A';
end

% msg=midi();%receiving a MIDI message (5 seconds)
% 
 gain=5;
% 
 freqs=zeros(1,D);
% time=0;
% m=2;
% for i=1:2*D
%     if(m<=length(msg))
%         if (msg(m).Timestamp-time-msg(m-1).Timestamp<0.01)
%             m=m+1;
%             time=0;
%         else
%             time=time+0.01;
%         end
%     else
%         m=length(msg);
%     end
%     if(msg(m-1).Velocity>0)
%         freqs(i)=440 * 2^((msg(m-1).Note-69)/12);
%     else
%         %note off
%         freqs(i)=30000;
%     end
% end
% 

freqs = music_file('flute.wav', L, D);

excitation_signal=zeros(1,N);
output=zeros(1,N);
win=1;
voiced=voiced_func(y,Fs,L);
for i=1: L :N-L
    if(voiced(win)==1)
        excitation_signal(i:i+L-1)=treno(L,freqs(win));
    else
        excitation_signal(i:i+L-1)=wgn(1,L,-50);
    end
    output(i:i+L-1)=filter(gain,coefs(win,:),excitation_signal(i:i+L-1));
    win=win+1;
end

%output_1 = (output - min(output)) / (max(output) - min(output)) * 2 -1;

audiowrite('output.wav',output,Fs);

