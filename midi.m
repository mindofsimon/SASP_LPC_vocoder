function [msg] = midi()
    device = mididevice('MPK Mini Mk II');
    %display('Start Playing');
    h1=helpdlg('Press OK to start recording','Record');%open dialog win
    uiwait(h1);%wait for confirmation
    pause(6);%5 for a little latency
    %display('Finish Playing');
    h2=helpdlg('Finished Recording','Record');%open dialog win
    uiwait(h2);%wait for confirmation
    msg = midireceive(device);
end

