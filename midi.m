function [total_msg] = midi(app)
    device = app.MIDIDropDown.Value;
    midiInput = mididevice(device);
    osc = audioOscillator('square', 'Amplitude', 0);
    deviceWriter = audioDeviceWriter;
    deviceWriter.SupportVariableSizeInput = true;
    deviceWriter.BufferSize = 64; % small buffer keeps MIDI latency low

    total_msg=[];
    
    h1=helpdlg('Press OK to start recording','Record');%open dialog win
    uiwait(h1);%wait for confirmation
    
    tic;
    elapsed_time=toc;
    
    while elapsed_time<7
        msgs = midireceive(midiInput);
        [a,b]=size(msgs);
        if(a&&b ~= 0)
            total_msg=[total_msg msgs];
        end
        for i = 1:numel(msgs)
            msg = msgs(i);
            if isNoteOn(msg)
                osc.Frequency = note2freq(msg.Note);
                osc.Amplitude = msg.Velocity/127;
            elseif isNoteOff(msg)
                if msg.Note == msg.Note
                    osc.Amplitude = 0;
                end
            end
        end
        deviceWriter(osc());
        elapsed_time=toc;
    end
    toc;
    h2=helpdlg('Finished Recording','Record');%open dialog win
    uiwait(h2);%wait for confirmation
end

function yes = isNoteOn(msg)
    yes = msg.Type == midimsgtype.NoteOn ...
        && msg.Velocity > 0;
end

function yes = isNoteOff(msg)
    yes = msg.Type == midimsgtype.NoteOff ...
        || (msg.Type == midimsgtype.NoteOn && msg.Velocity == 0);
end

function freq = note2freq(note)
    freqA = 440;
    noteA = 69;
    freq = freqA * 2.^((note-noteA)/12);
end
