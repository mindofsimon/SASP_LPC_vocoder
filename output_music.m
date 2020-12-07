function [y,stateTX,zcrTX] = output_music(x,frame_length,lpcOrder,overlap,window,duration_win)
    % Codec states
    sil = 0;
    voiced = 2;
    unvoiced = 1;

    G = [];
    lpc_mem = zeros(1, lpcOrder);  % filter memory

    % get the number of entiere frames in the input and truncate it
    x=x(:); len = length(x);

    if overlap ~= 0
        nframes = floor( len / (frame_length*(1-overlap)) );
        x = x(1:(nframes*frame_length*(1-overlap)));
    else
        nframes = floor( len / (frame_length) );
        x = x(1:(nframes*frame_length));
    end

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

    count_music=0;

    [audio_file, audio_fs]=audioread('flute.wav');
    
    if length(audio_file)>length(x)
        audio_file=audio_file(1:length(x));
    end
    
    for i=1:nframes-1
      
      % get current frame %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      xFrame = x( idx ).*window;
      idx = idx + floor(frame_length*(1-overlap));
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      % calculate frame energy (TODO) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      g = lpc_gain(xFrame); 
      ampTX(:,i) = g;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


      % sil / voiced / unvoiced decision (TODO) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % define a silence threshold (based on frame energy)
      % define a voiced threshold (based on zcr)
      [ state, zcr ] = voicing_decision( xFrame );
      stateTX(:,i) = state;
      zcrTX(:,i) = zcr;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
      if state == unvoiced || state == voiced
          [a, lpc_mem, res_xFrame ] = lpc_filter(xFrame, lpcOrder, lpc_mem);
          residualTX(:,i) = res_xFrame;                    % Prediction error
          aCoeffTX(:,i) = a;
      end
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      if state == voiced    
          [ltp,count_music]=music_file('flute.wav',frame_length,duration_win,count_music);
          pitchTX(:,i) = ltp;
      end
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end
    % ====================== CODER main loop (end) ==========================


    % ==================== DECODER main loop (start) ========================

    % initialize decoder variables
    y = zeros(length(x),1);

    randn('seed',0);                    % random noise
    lpc_mem = zeros(1, lpcOrder );    % memory of the LPC filter
    pitch_offset = 0;                       % memory of the LTP (pitch) filter

    idx = 1 : frame_length;

    for i=1:nframes-1

        % get sil / voiced / unvoiced decision %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        state = stateTX(i);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % get pitch delay %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ltpDelay = pitchTX(i);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % get LPC coefficients %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        a = aCoeffTX(:, i);     
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

        [excitation, pitch_offset] = excitation_synth(state, ltpDelay, pitch_offset, frame_length);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        [ lpc_output, lpc_mem ] = lpc_synth(excitation, a, lpc_mem);
    
        % signal scaling (TODO) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        amp = ampTX(i);
        lpc_power = sqrt(lpc_output' * lpc_output) / frame_length;
        %
        if lpc_power > 0
          gain = amp/lpc_power; 
        else
           gain = 0.0; 
        end
        yFrame = gain * lpc_output;
        g = lpc_gain(yFrame); 
        ampRX(:,i) = g;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % re-construct the output signal
        y( idx ) = yFrame;
        idx = idx + floor(frame_length*(1-overlap));

    end
end

