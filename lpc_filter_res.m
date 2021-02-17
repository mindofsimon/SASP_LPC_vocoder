function [res_audio_frame, cont] = lpc_filter_res(audio_file, order, cont, win_length)

      xFrame=audio_file(cont:cont+win_length);
      len = length(xFrame);
   
      % amplitude of input signal
      %
      amp = sqrt( xFrame' * xFrame / len );


      % linear prediction coefficients
      a = lpc( xFrame, order );
      coeff = a(2:end);

      [est_xFrame] = filter([0 -coeff], 1, xFrame);   % Estimated signal
      res_audio_frame = xFrame - est_xFrame;
      res_audio_frame = res_audio_frame(1:len-1);
      cont=cont+win_length;
end

