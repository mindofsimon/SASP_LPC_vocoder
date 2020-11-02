function [] = start_vocoder(app)
    if app.SamplesButton.Value==1
        input_file= app.InputDropDown.Value;
    else
        input_file=audio_recording();
    end
    
    [x, fs] = audioread(input_file);
    y = lpc_vocoder_main(x,fs,app);
end

