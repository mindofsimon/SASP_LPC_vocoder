function [input_file] = audio_recording()
duration = 5;
Fs = 44100;

prova_vocoder = audiorecorder(Fs,8,1);
h1=helpdlg('Press OK to start recording','Record');%open dialog win
uiwait(h1);%wait for confirmation
recordblocking(prova_vocoder, duration);
h2=helpdlg('Finished Recording','Record');%open dialog win
uiwait(h2);%wait for confirmation
myspeech = getaudiodata(prova_vocoder, 'double');
audiowrite('user_recording.wav', myspeech, Fs);
input_file=('user_recording.wav');
end

