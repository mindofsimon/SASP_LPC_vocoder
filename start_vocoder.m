function [] = start_vocoder(app)
    input_file='prova_vocoder_44_2.wav';
    [x, fs] = audioread(input_file);
    app.InputFileEditField.Value=input_file;
    
    y = lpc_vocoder_main(x,fs,app);
end

