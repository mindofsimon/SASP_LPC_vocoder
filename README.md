# SASP_LPC_vocoder
@POLIMI:MAE - SASP project A.Y. 2019/2020 - Daniele Leonzio, Simone Mariani

TO DOWNLOAD OUR (MATLAB) APP GO TO : https://separate-leaf.surge.sh/

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


