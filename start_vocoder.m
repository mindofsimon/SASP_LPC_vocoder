close all; clear all;

[x, fs] = audioread('prova_vocoder_44.wav');

y = lpc_vocoder_main(x,fs);


