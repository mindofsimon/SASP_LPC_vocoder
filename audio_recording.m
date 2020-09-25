clc 
clearvars
close all 

% [y, Fs_y] = audioread('prova_vocoder_44.wav');
duration = 5;
Fs = 16000; %16KHz

prova_vocoder = audiorecorder(Fs,8,1);
disp('Start speaking.')
recordblocking(prova_vocoder, duration);
disp('End of Recording.');
myspeech = getaudiodata(prova_vocoder, 'double');
audiowrite('prova_vocoder_16.wav', myspeech, Fs);


