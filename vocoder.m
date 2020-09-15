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
