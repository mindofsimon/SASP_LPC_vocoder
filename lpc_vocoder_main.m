function [ y ] = lpc_vocoder_main( x,fs,app )

% Simple LPC vocoder without quantization
% Input signal in the range -1:1 scaled to -32768 ... 32767
x = x/max(x);
x = x .* 2^15;
%duration_win=0.02;

%get input from interface
duration_win=app.FrameLengthEditField.Value/1000;%from milliseconds to seconds
win_type=app.WindowDropDown.Value;
overlap=app.OverlapEditField.Value/100;
res_file="AudioSamples\"+app.ResidualsFileDropDown.Value;

% Initialize codec parameters
frame_length = fs*duration_win;% 160 sample frames at 8kHz: 20 ms
%Setting Window Type
if(win_type=="Rectangular")
    window=rectwin(frame_length);
elseif(win_type=="Bartlett")
    window=bartlett(frame_length);
elseif(win_type=="Hamming")
    window=hamming(frame_length);
elseif(win_type=="Hanning")
    window=hann(frame_length);
elseif(win_type=="Blackman-Harris")
    window=blackman(frame_length);
end
lpcOrder = round(fs/1000)+2;      % LPC order
app.FsEditField.Value=fs;
app.LPCOrderEditField.Value=lpcOrder;

%Excitation Signal Mode
if(app.ExcitationSignalDropDown.Value=="MIDI")
    [y,state,zcr]=output_midi(x,frame_length,lpcOrder,overlap,window,duration_win);
elseif(app.ExcitationSignalDropDown.Value=="Music File")
    [y,state,zcr]=output_music(x,frame_length,lpcOrder,overlap,window,duration_win);
else
    [y,state,zcr]=output_residuals(x,frame_length,lpcOrder,overlap,window,res_file);
end

y = (y ./ 2^15);
audiowrite('output.wav',y,fs);

%APP Plots
t=0:(1/fs):(length(y)/fs);
app.AxesInput.YLimMode = 'manual';
app.AxesInput.YLim = [-1, 1];
app.AxesOutput.YLimMode = 'manual';
app.AxesOutput.YLim = [-1, 1];

x = x ./ 2^15;%just to put it again at -1:1 on Y axis

plot(app.AxesInput,t(1:end-1),x(1:length(y)));
plot(app.AxesOutput,t(1:end-1),y);
plot(app.AxesState,state);
plot(app.AxesZCR,zcr);

end

