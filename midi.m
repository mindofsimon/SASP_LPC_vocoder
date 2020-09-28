function [msg] = midi()
    device = mididevice('MPK Mini Mk II');
    display('Start Playing');
    pause(6);%5 for a little latency
    display('Finish Playing');
    msg = midireceive(device);
end

