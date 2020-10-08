function [] = start_vocoder_2(app)
    [x, fs] = audioread('prova_vocoder_44_2.wav');
    
    y = lpc_vocoder_main(x,fs,app);
end

