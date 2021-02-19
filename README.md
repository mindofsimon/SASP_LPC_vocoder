# SASP_LPC_vocoder
@POLIMI:MAE - SASP project A.Y. 2019/2020 - Daniele Leonzio, Simone Mariani

TO DOWNLOAD OUR (MATLAB) APP GO TO : https://separate-leaf.surge.sh/ , download and run the installer, then you will find the app in the MATLAB APPS tab.

IF YOU DOWNLOAD FROM THIS REPO: to start the app you will need to open the MATLAB console (be careful to have opened the folder containing all the files) and digit 'interface'.

YOU CAN WATCH A LITTLE DEMO HERE: https://drive.google.com/file/d/1tNaLKIKsz-u1dcheweFpPVvPStyfs1sj/view?usp=sharing

POWER POINT PRESENTATION HERE: https://docs.google.com/presentation/d/1DyQpeu_MZImMoFzP1hio0SIGBO2wOLfsqHAppR5FOwQ/edit?usp=sharing

LPC_Vocoder is a Matlab App, able to synthetize a voice based on the LPC parameter of an input signal.

The input signal can be recorded live or the user can choose among a pre-loaded collection.
The analysis parameters are totally parametric and we decided to give to the user the maximum freedom on this choice.

For the synthsis the user can choose between 3 modes to generate the excitation signal: MIDI, Music file (monophonic), Residuals.                  
With MIDI we create an excitation signal based on the fundamental frequency played by the user.                                   
With Music file, we extract the fundamental frequencies from a preloaded music file and the build a train of pulses based on these frequencies.                   
With Residual we apply the LPC estimation also on the music file and we will use the residual part as excitation signal. 
In this case the music file can be choosen by the user from a list inside the interface.

In the interface there is also a plot section, where we put the input and output waveform plots. We add also the state classification(voiced, unvoiced, silece) for each frame and the zero-crossing rate value for each frame.

To listen to the output file there is a button above the output plot, and in order to have a feedback we add also a button to listen to the input file and the music file. In the MIDI mode the music is played in real-time with a MATLAB synth.


