function [ y ] = lpc_vocoder_main( x,fs,app )

% Simple LPC vocoder without quantization
% Input signal in the range -1:1 scaled to -32768 ... 32767
x = x/max(x);
x = x .* 2^15;
%duration_win=0.02;

%get input from interface
duration_win=app.FrameLengthEditField.Value/1000;%from milliseconds to seconds
win_type=app.WindowDropDown.Value;
overlap=app.OverlapEditField.Value;

% Initialize codec parameters
frame_length = fs*duration_win;  % 160 sample frames at 8kHz: 20 ms
lpcOrder = round(fs/1000)+2;      % LPC order
app.FsEditField.Value=fs;
app.LPCOrderEditField.Value=lpcOrder;


% Codec states
sil = 1;
voiced = 2;
unvoiced = 3;

G = [];
lpc_mem = zeros(1, lpcOrder);  % filter memory

% get the number of entiere frames in the input and truncate it
x=x(:); len = length(x);
nframes = floor( len / frame_length );
x = x(1:(nframes*frame_length));

%= initialize data storage for transmitted parameters 
stateTX    = zeros(1,        nframes);
zcrTX    = zeros(1,        nframes);
ampTX      = zeros(1,        nframes);
ampRX      = zeros(1,        nframes);
aCoeffTX        = zeros(lpcOrder, nframes);
pitchTX = zeros(1,        nframes);
residualTX = zeros(frame_length, nframes);

% ====================== CODER main loop (start) ========================
idx = 1 : frame_length;

%msg = midi();
%count_midi=2;
%time=0;

count_music=0;
cont_audio=1;

[audio_file, audio_fs]=audioread('mistery-piano-violin-sad-melody.wav');

for i=1:nframes

  %fprintf(1,'-------------------- [%3d]\n',i);
      
  % get current frame (no overlap) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  xFrame = x( idx );
  idx = idx + frame_length;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % calculate frame energy (TODO) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  g = lpc_gain(xFrame); 
  ampTX(:,i) = g;
  %fprintf(1,'Gain: %f\n', g);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  
  % sil / voiced / unvoiced decision (TODO) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % define a silence threshold (based on frame energy)
  % define a voiced threshold (based on zcr)
  [ state, zcr ] = voicing_decision( xFrame );
  stateTX(:,i) = state;
  zcrTX(:,i) = zcr;
  %fprintf(1,'State: %d\n', state);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % calculate prediction residual (TODO) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %[~,ltp,count_midi,time,state_midi] = midi_freqs(msg, duration_win, frame_length, count_midi,time);
  
  if state == unvoiced | state == voiced
      %residuals part
      [residuals, cont_audio] = lpc_filter_res(audio_file, lpcOrder, cont_audio, frame_length);
      residualTX(:,i) = residuals;
      [a, lpc_mem, res_xFrame ] = lpc_filter(xFrame, lpcOrder, lpc_mem);
      %residualTX(:,i) = res_xFrame;                    % Prediction error
      
      %fprintf(1,'LPC coeffs: %f %f %f %f %f %f %f %f %f %f\n', ...
          %a(1), a(2), a(3), a(4), a(5), a(6), a(7), a(8), a(9), a(10));
      aCoeffTX(:,i) = a;
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % calculate pitch delay in samples (TODO) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   if state == voiced 
%       ltp = ltp_estimation( res_xFrame );
%       fprintf(1,'LTP: %d\n', ltp);
%       pitchTX(:,i) = ltp;
%   end
  
  if state == voiced %&& state_midi==2
      %[~,ltp,count_midi,time] = midi_freqs(msg, duration_win, frame_length, count_midi,time);
      %[ltp,count_music]=music_file('flute.wav',frame_length,duration_win,count_music);
      %fprintf(1,'LTP: %d\n', ltp);
      %pitchTX(:,i) = ltp;
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
end
% ====================== CODER main loop (end) ==========================


% ==================== DECODER main loop (start) ========================

% initialize decoder variables
y = zeros(nframes*frame_length,1);

randn('seed',0);                    % random noise
lpc_mem = zeros(1, lpcOrder );    % memory of the LPC filter
pitch_offset = 0;                       % memory of the LTP (pitch) filter

idx = 1 : frame_length;

for i=1:nframes,
    
    %fprintf(1,'-------------------- <%3d>\n',i);

    % get sil / voiced / unvoiced decision %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    state = stateTX(i);
    %fprintf(1,'State: %d\n', state);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
    % get pitch delay %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ltpDelay = pitchTX(i);
    %fprintf(1,'PitchDelay/offset: %d/%d\n', ltpDelay, pitch_offset);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % get LPC coefficients %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    a = aCoeffTX(:, i);     
    %fprintf(1,'LPC coeffs: %f %f %f %f %f %f %f %f %f %f\n', ...
          %a(1), a(2), a(3), a(4), a(5), a(6), a(7), a(8), a(9), a(10));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

    % TODO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % excitation = residualTX(:,i);   % !! REMOVE ME !!
    % and substitute with the excitation function below
    %[excitation, pitch_offset] = excitation_synth(state, ltpDelay, pitch_offset, frame_length);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    
    %residual part
    %[ lpc_output] = lpc_synth_res(residualTX(:,i), a);
    [ lpc_output, lpc_mem ] = lpc_synth(residualTX(:,i), a, lpc_mem);
    % speech synthesis by mean of the inverse LPC filter (TODO) %%%%%%%%%%
    % Note: keep filter memory
    %[ lpc_output, lpc_mem ] = lpc_synth(excitation, a, lpc_mem);
%    plot(lpc_output); pause(0.1);
    
    %yFrame = lpc_output;    % !! REMOVE ME !!
    % and substitute with the 'completed version' of the code below
    
    % signal scaling (TODO) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    amp = ampTX(i);
    lpc_power = sqrt(lpc_output' * lpc_output) / frame_length;
    %
    if lpc_power > 0
      % TODO: restore the original frame energy using 'amp' and 'lpc_power'
      gain = amp/lpc_power; % FIXME
    else
       gain = 0.0; 
    end
    yFrame = gain * lpc_output;
    %fprintf(1,'Gain: %f(%f)\n', gain, amp);
    g = lpc_gain(yFrame); 
    ampRX(:,i) = g;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % re-construct the output signal
    y( idx ) = yFrame;
    idx = idx + frame_length;
    
end

% ==================== DECODER main loop (end) ==========================



save 'vocoder_channel.mat' stateTX zcrTX ampTX ampRX aCoeffTX pitchTX residualTX


figure;
hold off;
plot(1:length(x),x./2^15,'-g');
hold on;
plot(1:length(y),y./2^15,'-b');

plot(frame_length.*(1:length(zcrTX)),zcrTX,'-xr');
plot(frame_length.*(1:length(pitchTX)),8./pitchTX,'-xm');
plot(frame_length.*(1:length(ampTX)),ampTX./2^10,'-*k');

legend('Input signal', 'Output signal', 'Zero crossing rate', 'Pitch lag', 'Energy');
hold off;

y = (y ./ 2^15);
audiowrite('output.wav',y,fs);

%APP Plots
plot(app.AxesInput,x);
plot(app.AxesOutput,y);
plot(app.AxesResiduals,residualTX);
plot(app.AxesZCR,zcrTX);

end

